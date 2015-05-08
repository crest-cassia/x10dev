import x10.util.ArrayList;
import x10.regionarray.Region;

public class MockSearchEngine implements SearchEngineI {

  val targetNumRuns = 100;

  def this() {
  }

  def debug( o: Any ): void {
    Console.ERR.println(o);
  }

  public def createInitialTask( table: Tables, searchRegion: Region{self.rank==Simulator.numParams} ): ArrayList[Task] {
    val newTasks = new ArrayList[Task]();
    val p = new Point( 30, 10, 0 )
    val ps = ParameterSet.findOrCreateParameterSet( table, point );
    val runs = ps.createRunsUpTo( table, targetNumRuns );
    for( run in runs ) {
      newTasks.add( run.generateTask() );
    }
    return newTasks;
  }

  public def onParameterSetFinished( table: Tables, finishedPS: ParameterSet ): ArrayList[Task] {
    val empty = new ArrayList[Task]();
    return empty;
  }
}

