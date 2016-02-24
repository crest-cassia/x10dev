package caravan.SearchEngines;

import x10.util.ArrayList;
import x10.regionarray.Region;
import x10.util.RailUtils;
import x10.io.File;

import caravan.*;

public class SensitivityAnalysisSearcher implements SearchEngineI {

  val targetNumRuns = 1;

  public def this() {
  }

  public def createInitialTask( table: Tables, searchRegion: Region{self.rank==Simulator.numParams} ): ArrayList[Task] {
    val newTasks = new ArrayList[Task]();

    Console.ERR.println("loading model_input.txt");
    val input = new File("model_input.txt");
    for( line in input.lines() ) {
      // Console.ERR.println( "line: " + line );
      val a: Rail[String]{self.size==Simulator.numParams} = line.split(" ") as Rail[String]{self.size==Simulator.numParams};
      val c: Rail[Long]{self.size==Simulator.numParams} = new Rail[Long]( a.size );
      RailUtils.map( a, c, (s:String) => Double.parse(s) as Long );
      val point: Point{self.rank==Simulator.numParams} = Point.make(c);
      Console.ERR.println( point );
      val ps = ParameterSet.findOrCreateParameterSet( table, point );
      val runs = ps.createRunsUpTo( table, targetNumRuns );
      for( run in runs ) {
        newTasks.add( run.generateTask() );
      }
      // Console.ERR.println( "Run was created:" + newTasks.size() );
    }
    Console.ERR.println( "finished loading:" + newTasks.size() );
    return newTasks;
  }

  public def onParameterSetFinished( table: Tables, finishedPS: ParameterSet ): ArrayList[Task] {
    val empty = new ArrayList[Task]();
    return empty;
  }
}

