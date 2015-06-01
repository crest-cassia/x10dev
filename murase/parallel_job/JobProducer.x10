import x10.util.ArrayList;
import x10.io.File;

class JobProducer {

  val tables: Tables;
  val engine: SearchEngineI;
  val taskQueue: ArrayList[Task];
  val sleepingBuffers: ArrayList[GlobalRef[JobBuffer]];

  def this( _tables: Tables, _engine: SearchEngineI ) {
    tables = _tables;
    engine = _engine;
    taskQueue = new ArrayList[Task]();
    enqueueInitialTasks();
    sleepingBuffers = new ArrayList[GlobalRef[JobBuffer]]();
  }

  private def enqueueInitialTasks() {
    val tasks = engine.createInitialTask( tables, Simulator.searchRegion() );
    for( task in tasks ) {
      taskQueue.add( task );
    }
  }

  public def registerSleepingBuffer( refBuffer: GlobalRef[JobBuffer] ) {
    atomic {
      sleepingBuffers.add( refBuffer );
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

    awakenSleepingBuffers();
  }

  private def awakenSleepingBuffers() {
    // `async at` must be called outside of atomic. Otherwise, you'll get a runtime exception.
    val refBuffers = new ArrayList[GlobalRef[JobBuffer]]();
    atomic {
      while( sleepingBuffers.size() > 0 ) {
        val refBuf = sleepingBuffers.removeFirst();
        refBuffers.add( refBuf );
      }
    }
    for( refBuf in refBuffers ) {
      async at( refBuf ) {
        refBuf().wakeUp();
      }
    }
  }

  public def popTasks(): ArrayList[Task] {
    val n = 1; // TODO: tune up parameters
    atomic {
      val tasks = new ArrayList[Task]();
      for( i in 1..n ) {
        if( taskQueue.size() == 0 ) break;
        val task = taskQueue.removeFirst();
        tasks.add( task );
      }
      return tasks;
    }
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

