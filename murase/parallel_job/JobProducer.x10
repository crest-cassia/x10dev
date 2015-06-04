import x10.util.ArrayList;
import x10.io.File;

class JobProducer {

  val m_tables: Tables;
  val m_engine: SearchEngineI;
  val m_taskQueue: ArrayList[Task];
  val m_sleepingConsumers: ArrayList[GlobalRef[JobConsumer]];

  def this( _tables: Tables, _engine: SearchEngineI ) {
    m_tables = _tables;
    m_engine = _engine;
    m_taskQueue = new ArrayList[Task]();
    enqueueInitialTasks();
    m_sleepingConsumers = new ArrayList[GlobalRef[JobConsumer]]();
  }

  private def enqueueInitialTasks() {
    val tasks = m_engine.createInitialTask( m_tables, Simulator.searchRegion() );
    for( task in tasks ) {
      m_taskQueue.add( task );
    }
  }

  public def registerSleepingConsumer( refConsumer: GlobalRef[JobConsumer] ) {
    atomic {
      m_sleepingConsumers.add( refConsumer );
    }
  }

  public def saveResult( res: JobConsumer.RunResult ) {
    atomic {
      val run = m_tables.runsTable.get( res.runId );
      run.storeResult( res.result, res.placeId, res.startAt, res.finishAt );
      val ps = run.parameterSet( m_tables );
      if( ps.isFinished( m_tables ) ) {
        val tasks = m_engine.onParameterSetFinished( m_tables, ps );
        for( task in tasks ) {
          m_taskQueue.add( task );
        }
      }
    }

    wakeUpSleepingConsumers( m_taskQueue.size() );
  }

  private def wakeUpSleepingConsumers( numConsumers: Long ) {
    // `async at` must be called outside of atomic. Otherwise, you'll get a runtime exception.
    val refConsumers = new ArrayList[GlobalRef[JobConsumer]]();
    atomic {
      for( i in 1..numConsumers ) {
        if( m_sleepingConsumers.size() == 0 ) { break; }
        val refConsumer = m_sleepingConsumers.removeFirst();
        refConsumers.add(refConsumer);
      }
    }
    for( refConsumer in refConsumers ) {
      async at( refConsumer ) {
        refConsumer().run();
      }
    }
  }

  public def popTasks(n: Long): ArrayList[Task] {
    atomic {
      val tasks = new ArrayList[Task]();
      for( i in 1..n ) {
        if( m_taskQueue.size() == 0 ) break;
        val task = m_taskQueue.removeFirst();
        tasks.add( task );
      }
      return tasks;
    }
  }

  public def printJSON( psJson: String, runsJson: String ) {
    val f = new File(runsJson);
    val p = f.printer();
    p.println( m_tables.runsJson() );
    p.flush();
    val f2 = new File(psJson);
    val p2 = f2.printer();
    p2.println( m_tables.parameterSetsJson() );
    p2.flush();
  }
}

