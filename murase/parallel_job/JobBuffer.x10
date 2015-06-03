import x10.util.ArrayList;
import x10.util.Timer;
import x10.interop.Java;
import org.json.simple.*;
import java.util.logging.Logger;

class JobBuffer {

  val m_refProducer: GlobalRef[JobProducer];
  val m_logger = Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);
  val m_taskQueue = new ArrayList[Task]();
  val m_resultsBuffer = new ArrayList[JobConsumer.RunResult]();
  var m_numRunning: Long = 0;
  val m_freePlaces = new ArrayList[Place]();

  def this( _refProducer: GlobalRef[JobProducer] ) {
    m_refProducer = _refProducer;
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
      atomic {
        for( task in tasks ) {
          m_taskQueue.add( task );
        }
      }
    }
  }

  def popTasks(): ArrayList[Task] {
    m_logger.fine("Buffer#popTasks " + m_numRunning + "/" + m_taskQueue.size() + " tasks at " + here);
    val n = 1;  // TODO: tune up number of return tasks
    val tasks = new ArrayList[Task]();
    fillTaskQueueIfEmpty();
    atomic {
      for( i in 1..n ) {
        if( m_taskQueue.size() == 0 ) {
          break;
        }
        val task = m_taskQueue.removeFirst();
        tasks.add( task );
        m_numRunning += 1;
      }
    }
    m_logger.fine("> Buffer#popTasks " + m_numRunning + "/" + m_taskQueue.size() + " tasks at " + here);
    return tasks;
  }

  def saveResult( result: JobConsumer.RunResult ) {
    val resultsToSave: ArrayList[JobConsumer.RunResult] = new ArrayList[JobConsumer.RunResult]();
    atomic {
      m_resultsBuffer.add( result );
      m_numRunning -= 1;
      if( m_resultsBuffer.size() >= 16 || m_numRunning == 0 ) { // TODO: set parameter
        while( m_resultsBuffer.size() > 0 ) {
          resultsToSave.add( m_resultsBuffer.removeFirst() );
        }
      }
    }

    val refProd = m_refProducer;
    at( refProd ) {
      refProd().saveResults( resultsToSave );
    }
  }

  def registerFreePlace( freePlace: Place ) {
    var registerToProducer: Boolean = false;
    atomic {
      if( m_freePlaces.isEmpty() ) {
        registerToProducer = true;
      }
      m_freePlaces.add( freePlace );
      m_logger.fine("Buffer#registerFreePlace " + m_freePlaces + " at " + here );
    }
    if( registerToProducer ) {
      m_logger.fine("Buffer#registerFreeBuffer at " + here );
      val refMe = new GlobalRef[JobBuffer]( this );
      val refProd = m_refProducer;
      at( refProd ) {
        refProd().registerFreeBuffer( refMe );
      }
    }
  }

  def wakeUp() {
    m_logger.fine("Buffer#wakeUp " + m_freePlaces + " at " + here);
    fillTaskQueueIfEmpty();
    m_logger.fine("Buffer#wakeUp -> fillTask : " + m_numRunning + "/" + m_taskQueue.size() + " tasks at " + here);
    launchConsumerAtFreePlace();
  }

  private def launchConsumerAtFreePlace() {
    // if( taskQueue.size() == 0 ) { return; }
    m_logger.fine("Buffer#launchConsumerAtFreePlace " + m_freePlaces + " at " + here );
    val freePlaces = new ArrayList[Place]();
    atomic {
      while( m_freePlaces.size() > 0 ) {
        val place = m_freePlaces.removeFirst();
        freePlaces.add( place );
      }
    }
    val refMe = new GlobalRef[JobBuffer]( this );
    for( place in freePlaces ) {
      m_logger.fine("Buffer#launchConsumerAtFreePlace : booting Consumer at " + place );
      async at( place ) {
        val consumer = new JobConsumer( refMe );
        consumer.run();
      }
    }
  }
}

