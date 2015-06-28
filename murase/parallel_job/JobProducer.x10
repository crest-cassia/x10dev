import x10.util.ArrayList;
import x10.io.File;
import x10.util.Timer;
import x10.util.concurrent.AtomicBoolean;
import util.MyLogger;

class JobProducer {

  val m_tables: Tables;
  val m_engine: SearchEngineI;
  val m_taskQueue: ArrayList[Task];
  val m_freeBuffers: ArrayList[GlobalRef[JobBuffer]];
  val m_numBuffers: Long;
  val m_timer = new Timer();
  var m_lastSavedAt: Long;
  val m_saveInterval: Long;
  var m_dumpFileIndex: Long;
  val m_logger: MyLogger = new MyLogger();

  def this( _tables: Tables, _engine: SearchEngineI, _numBuffers: Long, _saveInterval: Long ) {
    m_tables = _tables;
    m_engine = _engine;
    m_taskQueue = new ArrayList[Task]();
    if( m_tables.empty() ) {
      enqueueInitialTasks();
    } else {
      enqueueUnfinishedTasks();
    }
    m_freeBuffers = new ArrayList[GlobalRef[JobBuffer]]();
    m_numBuffers = _numBuffers;
    m_lastSavedAt = m_timer.milliTime();
    m_saveInterval = _saveInterval;
    m_dumpFileIndex = 0;
  }

  private def d(s:String) {
    m_logger.d(s);
  }

  private def enqueueInitialTasks() {
    val tasks = m_engine.createInitialTask( m_tables, Simulator.searchRegion() );
    for( task in tasks ) {
      m_taskQueue.add( task );
    }
  }

  private def enqueueUnfinishedTasks() {
    val tasks = m_tables.createTasksForUnfinishedRuns();
    for( task in tasks ) {
      m_taskQueue.add( task );
    }
  }

  public def registerFreeBuffer( refBuffer: GlobalRef[JobBuffer] ) {
    atomic {
      d("Producer registering free buffer");
      m_freeBuffers.add( refBuffer );
      d("Producer registered free buffer");
    }
  }

  public def saveResults( results: ArrayList[JobConsumer.RunResult] ) {
    atomic {
      d("Producer saving " + results.size() + " results");
      for( res in results ) {
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
      d("Producer saved " + results.size() + " results");
      serializePeriodically();
    }

    notifyFreeBuffer();
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

  private def notifyFreeBuffer() {
    d("Producer notifying free buffers");
    // `async at` must be called outside of atomic. Otherwise, you'll get a runtime exception.
    val refBuffers = new ArrayList[GlobalRef[JobBuffer]]();
    atomic {
      while( m_freeBuffers.size () > 0 && refBuffers.size() < m_taskQueue.size() ) {
        val freeBuf = m_freeBuffers.removeFirst();
        refBuffers.add( freeBuf );
      }
    }
    for( refBuf in refBuffers ) {
      at( refBuf ) {
        refBuf().wakeUp();
      }
    }
    d("Producer notified free buffers");
  }

  public def popTasks(): ArrayList[Task] {
    atomic {
      d("Producer popTasks is called");
      val tasks = new ArrayList[Task]();
      val n = calcNumTasksToPop();
      for( i in 1..n ) {
        if( m_taskQueue.size() == 0 ) break;
        val task = m_taskQueue.removeFirst();
        tasks.add( task );
      }
      d("Producer sending " + tasks.size() + " tasks to buffer");
      return tasks;
    }
  }

  private def calcNumTasksToPop(): Long {
    return Math.ceil((m_taskQueue.size() as Double) / (2.0*m_numBuffers)) as Long;
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

