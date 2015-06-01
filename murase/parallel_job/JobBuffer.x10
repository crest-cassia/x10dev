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
    logger.info(" starting buf#popTasks at " + here.id + " : " + taskQueue.size() + " : " + numRunning + " running tasks");
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
    logger.info(" ending buf#popTasks at " + here.id + " : " + taskQueue.size() + " : " + numRunning + " running tasks");
    // logger.info("   return Task " + tasks(0).runId );
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

  def wakeUp() {
    logger.info(" waking up Buffer " + here.id() + " :: " + sleepingConsumers );
    fillTaskQueueIfEmpty();
    awakenSleepingConsumers();
  }

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
      logger.info(" registered Consumer at " + here + " :: " + sleepingConsumers );
    }
    if( registerToProducer ) {
      logger.info(" registering free buffer : " + here.id() );
      val refMe = new GlobalRef[JobBuffer]( this );
      at( refProducer ) {
        refProducer().registerFreeBuffer( refMe );
      }
    }
  }

  private def awakenSleepingConsumers() {
    // if( taskQueue.size() == 0 ) { return; }
    logger.info(" awakening Consumer at " + here + " :: " + sleepingConsumers );
    val refConsumers = new ArrayList[GlobalRef[JobConsumer]]();
    atomic {
      while( sleepingConsumers.size() > 0 ) {
        val refCons = sleepingConsumers.removeFirst();
        refConsumers.add( refCons );
      }
    }
    for( refConsumer in sleepingConsumers ) {
      async at( refConsumer ) {
        refConsumer().run();
      }
    }
  }
}

