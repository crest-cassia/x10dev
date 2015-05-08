import x10.io.Console;
import x10.util.HashMap;
import x10.glb.GLBParameters;
import x10.glb.GLB;
import x10.util.Pair;
import x10.util.HashMap;
import x10.util.ArrayList;
import x10.io.File;

class Mock {

  def run( seed: Long ): void {
    val refTableSearcher = new GlobalRef[PairTablesSearchEngine](
      new PairTablesSearchEngine( new Tables( seed ), new MockSearchEngine() )
    );
    val newTasks = at( refTableSearcher ) {
      val tasks = refTableSearcher().searcher.createInitialTask( refTableSearcher().tables, Simulator.searchRegion() );
      return tasks;
    };
    val init = () => { return new JobQueue( refTableSearcher ); };
    val glb = new GLB[JobQueue, Long](init, GLBParameters.Default, true);

    Console.OUT.println("Starting ... ");
    val start = () => { glb.taskQueue().addInitialTasks( newTasks ); };
    val r = glb.run(start);
    Console.OUT.println("r : " + r);

    at( refTableSearcher ) {
      val f = new File("runs.json");
      val p = f.printer();
      p.println( refTableSearcher().tables.runsJson() );
      p.flush();
      val f2 = new File("parameter_sets.json");
      val p2 = f2.printer();
      p2.println( refTableSearcher().tables.parameterSetsJson() );
      p2.flush();
    }
  }

  static public def main( args: Rail[String] ) {
    val m = new Mock();
    val seed = Long.parse( args(0) );
    m.run( seed );
  }
}
