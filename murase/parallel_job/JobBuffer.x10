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
    val n = 1;  // TODO: tune up number of return tasks
    val tasks = new ArrayList[Task]();
    fillTaskQueueIfEmpty();
    awakenSleepingConsumers();
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
    if( taskQueue.size() == 0 ) {
      sleep();
    }
    return tasks;
  }

  private def sleep() {
    var goingToSleep: Boolean = false;
    atomic {
      if( !sleeping ) {
        sleeping = true;
        goingToSleep = true;
      }
    }
    if( goingToSleep ) {
      val refMe = new GlobalRef[JobBuffer]( this );
      at( refProducer ) {
        refProducer().registerSleepingBuffer( refMe );
      }
    }
  }

  def wakeUp() {
    atomic {
      sleeping = false;
    }
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
    atomic {
      sleepingConsumers.add( refCons );
    }
  }

  private def awakenSleepingConsumers() {
    if( taskQueue.size() == 0 ) { return; }
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

