import x10.util.ArrayList;
import x10.util.Timer;
import x10.interop.Java;
import org.json.simple.*;
import java.util.logging.Logger;

class JobConsumer {

  val refBuffer: GlobalRef[JobBuffer];
  val timer = new Timer();
  val logger = Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);

  def this( _refBuffer: GlobalRef[JobBuffer] ) {
    refBuffer = _refBuffer;
  }

  static struct RunResult(
    runId: Long,
    result: Simulator.OutputParameters,
    placeId: Long,
    startAt: Long,
    finishAt: Long
  ) {};

  def run() {
    logger.fine("Consumer#run " + here);
    val tasks = getTasksFromBuffer();
    while( tasks.size() > 0 ) {
      val task = tasks.removeFirst();
      val result = runTask( task );

      at( refBuffer ) {
        refBuffer().saveResult( result );
      }
      logger.fine("Consumer#saveResult " + result.runId + " at " + here);

      val newTasks = getTasksFromBuffer();
      for( newTask in newTasks ) {
        tasks.add( newTask );
      }
    }

    val refMe = new GlobalRef[JobConsumer]( this );
    at( refBuffer ) {
      refBuffer().registerSleepingConsumer( refMe );
    }
    logger.fine("> Consumer#run " + here);
  }

  private def runTask( task: Task ): RunResult {
    val runId = task.runId;
    logger.fine("Consumer#runTask " + runId + " at " + here);
    val startAt = timer.milliTime();
    val runPlace = here.id;
    val localResult = task.run();
    val finishAt = timer.milliTime();
    val result = RunResult( runId, localResult, runPlace, startAt, finishAt );
    return result;
  }

  def getTasksFromBuffer(): ArrayList[Task] {
    val tasks = at( refBuffer ) {
      return refBuffer().popTasks();
    };
    return tasks;
  }
}
