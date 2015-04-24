import x10.io.Console;
import x10.util.HashMap;
import x10.glb.GLBParameters;
import x10.glb.GLB;
import x10.util.Pair;
import x10.util.HashMap;
import x10.util.ArrayList;

class Main {

  def run( seed: Long ): void {
    val refTableSearcher = new GlobalRef[PairTablesSearcher](
      new PairTablesSearcher( new Tables( seed ), new GridSearcher() )
    );
    val newTasks = at( refTableSearcher ) {
      val tasks = refTableSearcher().searcher.makeInitialBox( refTableSearcher().tables, 0.2, 0.3, -1.0, 1.0 );
      return tasks;
    };
    val init = () => { return new JobQueue( refTableSearcher ); };
    val glb = new GLB[JobQueue, Long](init, GLBParameters.Default, true);

    Console.OUT.println("Starting ... ");
    val start = () => { glb.taskQueue().addInitialTasks( newTasks ); };
    val r = glb.run(start);
    Console.OUT.println("r : " + r);

    at( refTableSearcher ) {
      Console.OUT.println( refTableSearcher().tables.runsJson() );
    }
  }

  static public def main( args: Rail[String] ) {
    val m = new Main();
    val seed = Long.parse( args(0) );
    m.run( seed );
  }
}
