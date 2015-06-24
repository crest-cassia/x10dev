import x10.util.ArrayList;
import x10.io.File;
import x10.util.Timer;

class JobProducer {

  val m_tables: Tables;
  val m_engine: SearchEngineI;
  val m_taskQueue: ArrayList[Task];
  val m_freePlaces: ArrayList[Place] = new ArrayList[Place]();
  val m_timer = new Timer();
  var m_lastSavedAt: Long;
  val m_saveInterval: Long;
  var m_dumpFileIndex: Long;

  def this( _tables: Tables, _engine: SearchEngineI, _saveInterval: Long ) {
    m_tables = _tables;
    m_engine = _engine;
    m_taskQueue = new ArrayList[Task]();
    enqueueInitialTasks();
    m_lastSavedAt = m_timer.milliTime();
    m_saveInterval = _saveInterval;
    m_dumpFileIndex = 0;
  }

  private def enqueueInitialTasks() {
    val tasks = m_engine.createInitialTask( m_tables, Simulator.searchRegion() );
    for( task in tasks ) {
      m_taskQueue.add( task );
    }
  }

  public def registerFreePlace( place: Place ) {
    atomic {
      m_freePlaces.add( place );
    }
  }

  public def saveResult( res: JobConsumer.RunResult ) {
    val qSize: Long;
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
      serializePeriodically();
      qSize = m_taskQueue.size();
    }

    launchConsumersAtFreePlace( qSize );
  }

  private def serializePeriodically() {
    val now = m_timer.milliTime();
    if( now - m_lastSavedAt > m_saveInterval ) {
      val psjson = "parameter_sets_" + m_dumpFileIndex + ".json";
      val runjson = "runs_" + m_dumpFileIndex + ".json";
      printJSON(psjson, runjson);
      m_lastSavedAt = now;
      m_dumpFileIndex += 1;
    }
  }

  private def launchConsumersAtFreePlace( numConsumers: Long ) {
    // `async at` must be called outside of atomic. Otherwise, you'll get a runtime exception.
    val freePlaces = new ArrayList[Place]();
    atomic {
      for( i in 1..numConsumers ) {
        if( m_freePlaces.size() == 0 ) { break; }
        val p = m_freePlaces.removeFirst();
        freePlaces.add( p );
      }
    }
    val refMe = new GlobalRef[JobProducer]( this );
    for( place in freePlaces ) {
      async at( place ) {
        val consumer = new JobConsumer( refMe );
        consumer.run();
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

