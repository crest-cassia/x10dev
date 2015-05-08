import x10.util.ArrayList;
// import x10.glb.ArrayListTaskBag;
import x10.glb.TaskQueue;
import x10.glb.TaskBag;
import x10.glb.GLBParameters;
import x10.glb.GLB;
import x10.util.Team;
import x10.glb.Context;
import x10.glb.ContextI;
import x10.glb.GLBResult;
import x10.compiler.Native;
import x10.util.HashMap;
import x10.io.File;
import x10.util.Timer;
import x10.util.Pair;
import x10.interop.Java;
import org.json.simple.*;
import java.util.logging.Logger;

class JobQueue implements TaskQueue[JobQueue, Long] {
  val tb = new FifoTaskBag[Task]();
  val refTableSearcher: GlobalRef[ PairTablesSearchEngine ];
  val timer: Timer = new Timer();
  val logger = Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);


  public def this( _refTableSearcher: GlobalRef[ PairTablesSearchEngine ] ) {
    refTableSearcher = _refTableSearcher;
  }

  public def addInitialTasks( tasks: ArrayList[Task] ): void {
    for( task in tasks ) {
      tb.bag().add( task );
    }
  }

  public def process(var n:Long, context: Context[JobQueue,Long]):Boolean {
    context.yield();

    for( var i:Long = 0; tb.bag().size() > 0 && i < n; i++) {
      val task = tb.bag().removeFirst();
      val runId = task.runId;
      logger.info("running at " + here + " processing " + runId);
      val startAt = timer.milliTime();
      val runPlace = here.id;
      val localResult = task.run();
      val finishAt = timer.milliTime();

      val appendTask = ( added: ArrayList[Task], toAdd: ArrayList[Task] ) => {
        for( task in toAdd ) {
          added.add( task );
        }
      };

      val newTasks = at( refTableSearcher ) {
        val localNewTasks: ArrayList[Task] = new ArrayList[Task]();
        val tables = refTableSearcher().tables;
        val searcher = refTableSearcher().searcher;
        val run = tables.runsTable.get( runId );
        atomic {
          run.storeResult( localResult, runPlace, startAt, finishAt );
          val ps = run.parameterSet( tables );
          if( ps.isFinished( tables ) ) {
            val tasks = searcher.onParameterSetFinished( tables, ps );
            appendTask( localNewTasks, tasks );
          }
        }
        return localNewTasks;
      };

      appendTask( tb.bag(), newTasks );
      context.yield();
    }
    return tb.bag().size() > 0;
  }

  public def count() {
    return 0;
  }

  public def merge( var _tb: TaskBag): void { 
    logger.finer("JobQueue#merge at " + here );
    tb.merge( _tb as FifoTaskBag[Task]);
  }
  
  public def split(): TaskBag {
    logger.finer("JobQueue#split at " + here);
    return tb.split();
  }

  public def printLog(): void {
  }

  public def getResult(): MyResult {
    return new MyResult();
  }

  class MyResult extends GLBResult[Long] {

    public def this() {
    }

    public def getResult():x10.lang.Rail[Long] {
      val r = new Rail[Long](1);
      r(0) = 0;
      return r;
    }

    public def getReduceOperator():Int {
      return Team.ADD;
    }

    public def display(r:Rail[Long]):void {
    }
  }
}

