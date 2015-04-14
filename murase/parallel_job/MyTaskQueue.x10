import x10.util.ArrayList;
import x10.glb.ArrayListTaskBag;
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
import x10.interop.Java;
import org.json.simple.*;

class MyTaskQueue implements TaskQueue[MyTaskQueue, Long] {
  val tb = new ArrayListTaskBag[Task]();
  val refTables: GlobalRef[Tables];
  val timer: Timer = new Timer();

  public def this( _refTables: GlobalRef[Tables] ) {
    refTables = _refTables;
  }
  
  public def init(): void {
    val tasks = at( refTables ) {
      val a: ArrayList[Task] = new ArrayList[Task]();
      for( entry in refTables().runsTable.entries() ) {
        val run = entry.getValue();
        val task = run.generateTask();
        a.add( task );
      }
      return a;
    };

    for( task in tasks ) {
      tb.bag().add( task );
    }
  }

  public def process(var n:Long, context: Context[MyTaskQueue,Long]):Boolean {
    context.yield();

    for( var i:Long = 0; tb.bag().size() > 0 && i < n; i++) {
      val task = tb.bag().removeLast();
      val runId = task.runId;
      Console.OUT.println("running at " + here + " processing " + runId);
      val startAt = timer.milliTime();
      val runPlace = here.id;
      val localResult = task.run();
      val finishAt = timer.milliTime();

      val appendTask = ( added: ArrayList[Task], toAdd: ArrayList[Task] ) => {
        for( task in toAdd ) {
          added.add( task );
        }
      };

      val newTasks = at( refTables ) {
        val localTasks = new ArrayList[Task]();
        val run = refTables().runsTable.get( runId );
        atomic {
          run.storeResult( localResult, runPlace, startAt, finishAt );
          val boxes = run.parameterSet( refTables() ).boxes( refTables() );
          Console.OUT.println("  boxes : " + boxes );
          for( box in boxes ) {
            if( refTables().boxNeedsToBeDivided( box.id ) ) {
              Console.OUT.println(" dividing box... ");
              val newTasks = refTables().divideBox( box.id );
              appendTask( localTasks, newTasks );
            }
          }
        }
        return localTasks;
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
    Console.OUT.println("MyTaskQueue#merge at " + here );
    tb.merge( _tb as ArrayListTaskBag[Task]);
  }
  
  public def split(): TaskBag {
    Console.OUT.println("MyTaskQueue#split at " + here);
    return tb.split();
  }

  public def printLog(): void {
    Console.OUT.println("MyTaskQueue#printLog at " + here);
  }

  public def getResult(): MyResult {
    Console.OUT.println("MyTaskQueue#getResult at " + here);
    return new MyResult(0);
  }

  class MyResult extends GLBResult[Long] {
    val result: Long;

    public def this(local_result:Long) {
      Console.OUT.println("constructor of MyResult");
      result = local_result;
    }

    public def getResult():x10.lang.Rail[Long] {
      val r = new Rail[Long](1);
      r(0) = result;
      Console.OUT.println("MyResult#getResult at " + here + " : " + r );
      return r;
    }

    public def getReduceOperator():Int {
      return Team.ADD;
    }

    public def display(r:Rail[Long]):void {
      Console.OUT.println("MyResult#display: " + r(0));
    }
  }
}

