import x10.util.ArrayList;
import x10.util.Timer;
import x10.interop.Java;
import org.json.simple.*;
import java.util.logging.Logger;

class JobConsumer {

  val m_refBuffer: GlobalRef[JobBuffer];
  val m_timer = new Timer();
  val m_logger = Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);

  def this( _refBuffer: GlobalRef[JobBuffer] ) {
    m_refBuffer = _refBuffer;
  }

  static struct RunResult(
    runId: Long,
    result: Simulator.OutputParameters,
    placeId: Long,
    startAt: Long,
    finishAt: Long
  ) {};

  def run() {
    m_logger.fine("Consumer#run " + here);
    val tasks = getTasksFromBuffer();
    while( tasks.size() > 0 ) {
      val task = tasks.removeFirst();
      val result = runTask( task );

      at( m_refBuffer ) {
        m_refBuffer().saveResult( result );
      }
      m_logger.fine("Consumer#saveResult " + result.runId + " at " + here);

      val newTasks = getTasksFromBuffer();
      for( newTask in newTasks ) {
        tasks.add( newTask );
      }
    }

    val refMe = new GlobalRef[JobConsumer]( this );
    at( m_refBuffer ) {
      m_refBuffer().registerSleepingConsumer( refMe );
    }
    m_logger.fine("> Consumer#run " + here);
  }

  private def runTask( task: Task ): RunResult {
    val runId = task.runId;
    m_logger.fine("Consumer#runTask " + runId + " at " + here);
    val startAt = m_timer.milliTime();
    val runPlace = here.id;
    val localResult = task.run();
    val finishAt = m_timer.milliTime();
    val result = RunResult( runId, localResult, runPlace, startAt, finishAt );
    return result;
  }

  def getTasksFromBuffer(): ArrayList[Task] {
    val tasks = at( m_refBuffer ) {
      return m_refBuffer().popTasks();
    };
    return tasks;
  }
}
