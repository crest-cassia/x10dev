import x10.util.ArrayList;
import x10.util.Timer;
import x10.interop.Java;
import org.json.simple.*;
import java.util.logging.Logger;

class JobConsumer {

  val refProducer: GlobalRef[JobProducer];
  val timer = new Timer();
  val logger = Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);

  def this( _refProcuer: GlobalRef[JobProducer] ) {
    refProducer = _refProcuer;
  }

  static struct RunResult(
    runId: Long,
    result: Simulator.OutputParameters,
    placeId: Long,
    startAt: Long,
    finishAt: Long
  ) {};

  def run() {
    val tasks = getTasksFromProducer();
    while( tasks.size() > 0 ) {
      val task = tasks.removeFirst();
      val runId = task.runId;
      logger.info("running at " + here + " processing " + runId);
      val startAt = timer.milliTime();
      val runPlace = here.id;
      val localResult = task.run();
      val finishAt = timer.milliTime();
      val result = RunResult( runId, localResult, runPlace, startAt, finishAt );

      storeResult( result );
      val newTasks = getTasksFromProducer();
      for( newTask in newTasks ) {
        tasks.add( newTask );
      }
    }

    val refMe = new GlobalRef[JobConsumer]( this );
    at( refProducer ) {
      refProducer().registerSleepingConsumer( refMe );
    }
  }

  def storeResult( result: RunResult ) {
    at( refProducer ) {
      refProducer().saveResult( result );
    }
  }

  def getTasksFromProducer(): ArrayList[Task] {
    val tasks = at( refProducer ) {
      return refProducer().popTasks(1);
    };
    return tasks;
  }
}
