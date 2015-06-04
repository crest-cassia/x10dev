import x10.util.ArrayList;
import x10.util.Timer;
import x10.interop.Java;
import org.json.simple.*;
import java.util.logging.Logger;

class JobConsumer {

  val m_refProducer: GlobalRef[JobProducer];
  val m_timer = new Timer();
  val m_logger = Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);

  def this( _refProcuer: GlobalRef[JobProducer] ) {
    m_refProducer = _refProcuer;
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
      m_logger.info("running at " + here + " processing " + runId);
      val startAt = m_timer.milliTime();
      val runPlace = here.id;
      val localResult = task.run();
      val finishAt = m_timer.milliTime();
      val result = RunResult( runId, localResult, runPlace, startAt, finishAt );

      storeResult( result );
      val newTasks = getTasksFromProducer();
      for( newTask in newTasks ) {
        tasks.add( newTask );
      }
    }

    val refMe = new GlobalRef[JobConsumer]( this );
    at( m_refProducer ) {
      m_refProducer().registerSleepingConsumer( refMe );
    }
  }

  def storeResult( result: RunResult ) {
    at( m_refProducer ) {
      m_refProducer().saveResult( result );
    }
  }

  def getTasksFromProducer(): ArrayList[Task] {
    val tasks = at( m_refProducer ) {
      return m_refProducer().popTasks(1);
    };
    return tasks;
  }
}
