import x10.util.ArrayList;
import x10.util.Timer;
// import x10.interop.Java;
// import org.json.simple.*;
// import java.util.logging.Logger;

class JobConsumer {

  val m_refProducer: GlobalRef[JobProducer];
  val m_timer = new Timer();
  var m_timeOut: Long = -1;
  // val m_logger = Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);

  def this( _refProcuer: GlobalRef[JobProducer] ) {
    m_refProducer = _refProcuer;
  }

  def setExpiration( timeOutMilliTime: Long ) {
    m_timeOut = m_timer.milliTime() + timeOutMilliTime;
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
      // m_logger.info("running at " + here + " processing " + runId);
      val startAt = m_timer.milliTime();
      val runPlace = here.id;
      val localResult = task.run();
      val finishAt = m_timer.milliTime();
      val result = RunResult( runId, localResult, runPlace, startAt, finishAt );

      storeResult( result );

      if( isExpired() ) { return; }
      val newTasks = getTasksFromProducer();
      for( newTask in newTasks ) {
        tasks.add( newTask );
      }
    }

    val place = here;
    val refProd = m_refProducer;
    at( refProd ) {
      refProd().registerFreePlace( place );
    }
  }

  def storeResult( result: RunResult ) {
    val refProd = m_refProducer;
    at( refProd ) {
      refProd().saveResult( result );
    }
  }

  def getTasksFromProducer(): ArrayList[Task] {
    val refProd = m_refProducer;
    val tasks = at( refProd ) {
      return refProd().popTasks(1);
    };
    return tasks;
  }

  private def isExpired(): Boolean {
    return ((m_timeOut > 0) && (m_timer.milliTime() > m_timeOut));
  }
}
