import x10.util.ArrayList;
import x10.util.Timer;
// import x10.interop.Java;
// import org.json.simple.*;
// import java.util.logging.Logger;

class JobBuffer {

  val m_refProducer: GlobalRef[JobProducer];
  // val m_logger = Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);
  val m_taskQueue = new ArrayList[Task]();
  val m_resultsBuffer = new ArrayList[JobConsumer.RunResult]();
  var m_numRunning: Long = 0;
  val m_freePlaces = new ArrayList[Place]();
  val m_numConsumers: Long;  // number of consumers belonging to this buffer

  def this( _refProducer: GlobalRef[JobProducer], _numConsumers: Long ) {
    m_refProducer = _refProducer;
    m_numConsumers = _numConsumers;
  }

  public def getInitialTasks() {
    fillTaskQueueIfEmpty();
  }

  private def fillTaskQueueIfEmpty(): void {
    if( m_taskQueue.size() == 0 ) {
      val refProd = m_refProducer;
      val tasks = at( refProd ) {
        return refProd().popTasks();
      };
      // if( here.id == 4 ) { Console.ERR.println(" got " + tasks.size() + " tasks from producer"); }
      atomic {
        for( task in tasks ) {
          m_taskQueue.add( task );
        }
      }
    }
  }

  def popTasks(): ArrayList[Task] {
    // m_logger.fine("Buffer#popTasks " + m_numRunning + "/" + m_taskQueue.size() + " tasks at " + here);
    val tasks = new ArrayList[Task]();
    fillTaskQueueIfEmpty();
    atomic {
      val n = calcNumTasksToPop();
      // if( here.id == 4 ) { Console.ERR.println("at " + here + " poping " + n + "tasks"); }
      for( i in 1..n ) {
        if( m_taskQueue.size() == 0 ) {
          break;
        }
        val task = m_taskQueue.removeFirst();
        tasks.add( task );
        m_numRunning += 1;
      }
    }
    // m_logger.fine("> Buffer#popTasks " + m_numRunning + "/" + m_taskQueue.size() + " tasks at " + here);
    return tasks;
  }

  private def calcNumTasksToPop(): Long {
    return Math.ceil((m_taskQueue.size() as Double) / (2.0*m_numConsumers)) as Long;
  }

  def saveResult( result: JobConsumer.RunResult ) {
    val resultsToSave: ArrayList[JobConsumer.RunResult] = new ArrayList[JobConsumer.RunResult]();
    atomic {
      m_resultsBuffer.add( result );
      m_numRunning -= 1;
      if( hasEnoughResults() ) { // TODO: set parameter
        // if( here.id == 4 ) { Console.ERR.println("saving " + m_resultsBuffer.size() + "results at " + here); }
        for( res in m_resultsBuffer ) {
          resultsToSave.add( res );
        }
        m_resultsBuffer.clear();
      }
    }

    val refProd = m_refProducer;
    at( refProd ) {
      refProd().saveResults( resultsToSave );
    }
  }

  private def hasEnoughResults(): Boolean {
    // return (m_resultsBuffer.size() >= 1 || m_numRunning == 0);
    return (m_resultsBuffer.size() >= m_numRunning  + m_taskQueue.size() );
  }

  def registerFreePlace( freePlace: Place ) {
    var registerToProducer: Boolean = false;
    atomic {
      if( m_freePlaces.isEmpty() ) {
        registerToProducer = true;
      }
      m_freePlaces.add( freePlace );
      // m_logger.fine("Buffer#registerFreePlace " + m_freePlaces + " at " + here );
    }
    if( registerToProducer ) {
      // m_logger.fine("Buffer#registerFreeBuffer at " + here );
      val refMe = new GlobalRef[JobBuffer]( this );
      val refProd = m_refProducer;
      at( refProd ) {
        refProd().registerFreeBuffer( refMe );
      }
    }
  }

  def wakeUp() {
    // m_logger.fine("Buffer#wakeUp " + m_freePlaces + " at " + here);
    fillTaskQueueIfEmpty();
    // m_logger.fine("Buffer#wakeUp -> fillTask : " + m_numRunning + "/" + m_taskQueue.size() + " tasks at " + here);
    launchConsumerAtFreePlace();
  }

  private def launchConsumerAtFreePlace() {
    // if( taskQueue.size() == 0 ) { return; }
    // m_logger.fine("Buffer#launchConsumerAtFreePlace " + m_freePlaces + " at " + here );
    val freePlaces = new ArrayList[Place]();
    atomic {
      for( place in m_freePlaces ) {
        freePlaces.add( place );
      }
      m_freePlaces.clear();
    }
    val refMe = new GlobalRef[JobBuffer]( this );
    for( place in freePlaces ) {
      // m_logger.fine("Buffer#launchConsumerAtFreePlace : booting Consumer at " + place );
      async at( place ) {
        val consumer = new JobConsumer( refMe );
        consumer.run();
      }
    }
  }
}

