import x10.util.ArrayList;
import x10.util.Timer;
import x10.interop.Java;
import org.json.simple.*;
import java.util.logging.Logger;

class JobBuffer {

  val refProducer: GlobalRef[JobProducer];
  val logger = Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);
  val taskQueue = new ArrayList[Task]();
  val resultsBuffer = new ArrayList[JobConsumer.RunResult]();
  var numRunning: Long = 0;
  val sleepingConsumers = new ArrayList[GlobalRef[JobConsumer]]();
  var sleeping: Boolean = false;

  def this( _refProducer: GlobalRef[JobProducer] ) {
    refProducer = _refProducer;
  }

  public def getInitialTasks() {
    fillTaskQueueIfEmpty();
  }

  private def fillTaskQueueIfEmpty(): void {
    if( taskQueue.size() == 0 ) {
      val tasks = at( refProducer ) {
        return refProducer().popTasks();
      };
      atomic {
        for( task in tasks ) {
          taskQueue.add( task );
        }
      }
    }
  }

  def popTasks(): ArrayList[Task] {
    logger.info("Buffer#popTasks " + numRunning + "/" + taskQueue.size() + " tasks at " + here);
    val n = 1;  // TODO: tune up number of return tasks
    val tasks = new ArrayList[Task]();
    fillTaskQueueIfEmpty();
    atomic {
      for( i in 1..n ) {
        if( taskQueue.size() == 0 ) {
          break;
        }
        val task = taskQueue.removeFirst();
        tasks.add( task );
        numRunning += 1;
      }
    }
    logger.info("> Buffer#popTasks " + numRunning + "/" + taskQueue.size() + " tasks at " + here);
    return tasks;
  }

  /*
  private def sleepIfEmpty() {
    var goingToSleep: Boolean = false;
    atomic {
      if( !sleeping && taskQueue.size() == 0 ) {
        sleeping = true;
        goingToSleep = true;
      }
    }
    if( goingToSleep ) {
      logger.info(" goingToSleep : Buffer" + here.id() );
      val refMe = new GlobalRef[JobBuffer]( this );
      at( refProducer ) {
        refProducer().registerSleepingBuffer( refMe );
      }
    }
  }
  */

  def saveResult( result: JobConsumer.RunResult ) {
    val resultsToSave: ArrayList[JobConsumer.RunResult] = new ArrayList[JobConsumer.RunResult]();
    atomic {
      resultsBuffer.add( result );
      numRunning -= 1;
      if( resultsBuffer.size() >= 4 || numRunning == 0 ) { // TODO: set parameter
        while( resultsBuffer.size() > 0 ) {
          resultsToSave.add( resultsBuffer.removeFirst() );
        }
      }
    }

    at( refProducer ) {
      refProducer().saveResults( resultsToSave );
    }
  }

  def registerSleepingConsumer( refCons: GlobalRef[JobConsumer] ) {
    var registerToProducer: Boolean = false;
    atomic {
      if( sleepingConsumers.isEmpty() ) {
        registerToProducer = true;
      }
      sleepingConsumers.add( refCons );
      logger.info("Buffer#registerSleepingConsumer " + sleepingConsumers + " at " + here );
    }
    if( registerToProducer ) {
      logger.info("Buffer#registerFreeBuffer at " + here );
      val refMe = new GlobalRef[JobBuffer]( this );
      at( refProducer ) {
        refProducer().registerFreeBuffer( refMe );
      }
    }
  }

  def wakeUp() {
    logger.info("Buffer#wakeUp " + sleepingConsumers + " at " + here);
    fillTaskQueueIfEmpty();
    logger.info("Buffer#wakeUp -> fillTask : " + numRunning + "/" + taskQueue.size() + " tasks at " + here);
    awakenSleepingConsumers();
  }

  private def awakenSleepingConsumers() {
    // if( taskQueue.size() == 0 ) { return; }
    logger.info("Buffer#awakenSleepingConsumers " + sleepingConsumers + " at " + here );
    val refConsumers = new ArrayList[GlobalRef[JobConsumer]]();
    atomic {
      while( sleepingConsumers.size() > 0 ) {
        val refCons = sleepingConsumers.removeFirst();
        refConsumers.add( refCons );
      }
    }
    for( refConsumer in sleepingConsumers ) {
      logger.info("Buffer#awakenSleepingConsumers : booting Consumer at " + refConsumer.home );
      async at( refConsumer ) {
        refConsumer().run();
      }
    }
  }
}

