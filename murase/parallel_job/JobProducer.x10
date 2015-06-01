import x10.util.ArrayList;
import x10.io.File;

class JobProducer {

  val tables: Tables;
  val engine: SearchEngineI;
  val taskQueue: ArrayList[Task];
  val freeBuffers: ArrayList[GlobalRef[JobBuffer]];
  val numBuffers: Long;

  def this( _tables: Tables, _engine: SearchEngineI, _numBuffers: Long ) {
    tables = _tables;
    engine = _engine;
    taskQueue = new ArrayList[Task]();
    enqueueInitialTasks();
    freeBuffers = new ArrayList[GlobalRef[JobBuffer]]();
    numBuffers = _numBuffers;
  }

  private def enqueueInitialTasks() {
    val tasks = engine.createInitialTask( tables, Simulator.searchRegion() );
    for( task in tasks ) {
      taskQueue.add( task );
    }
  }

  public def registerFreeBuffer( refBuffer: GlobalRef[JobBuffer] ) {
    atomic {
      freeBuffers.add( refBuffer );
    }
  }

  public def saveResults( results: ArrayList[JobConsumer.RunResult] ) {
    atomic {
      for( res in results ) {
        val run = tables.runsTable.get( res.runId );
        run.storeResult( res.result, res.placeId, res.startAt, res.finishAt );
        val ps = run.parameterSet( tables );
        if( ps.isFinished( tables ) ) {
          val tasks = engine.onParameterSetFinished( tables, ps );
          for( task in tasks ) {
            taskQueue.add( task );
          }
        }
      }
    }

    if( taskQueue.size() > 0 ) {
      notifyFreeBuffer();
    }
  }

  private def notifyFreeBuffer() {
    // `async at` must be called outside of atomic. Otherwise, you'll get a runtime exception.
    if( taskQueue.size() == 0 ) { return; }
    val refBuffers = new ArrayList[GlobalRef[JobBuffer]]();
    atomic {
      while( freeBuffers.size() > 0 && refBuffers.size() <= taskQueue.size() ) {
        val refBuf = freeBuffers.removeFirst();
        refBuffers.add( refBuf );
      }
    }
    for( refBuf in refBuffers ) {
      at( refBuf ) {
        refBuf().wakeUp();
      }
    }
  }

  public def popTasks(): ArrayList[Task] {
    atomic {
      val tasks = new ArrayList[Task]();
      val n = calcNumTasksToPop();
      for( i in 1..n ) {
        if( taskQueue.size() == 0 ) break;
        val task = taskQueue.removeFirst();
        tasks.add( task );
      }
      return tasks;
    }
  }

  private def calcNumTasksToPop(): Long {
    return Math.ceil((taskQueue.size() as Double) / (2.0*numBuffers)) as Long;
  }

  public def printJSON( psJson: String, runsJson: String ) {
    val f = new File(runsJson);
    val p = f.printer();
    p.println( tables.runsJson() );
    p.flush();
    val f2 = new File(psJson);
    val p2 = f2.printer();
    p2.println( tables.parameterSetsJson() );
    p2.flush();
  }
}

