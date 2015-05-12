import x10.io.Console;
import x10.util.HashMap;
import x10.glb.GLBParameters;
import x10.glb.GLB;
import x10.util.Pair;
import x10.util.HashMap;
import x10.util.ArrayList;
import x10.io.File;
import x10.interop.Java;
import java.util.logging.Logger;
import java.util.logging.Level;
import java.util.logging.Handler;

class Mock {

  def run( seed: Long, engine: SearchEngineI ): void {
    val logger = Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);
    logger.setLevel(Level.INFO);   // set Level.ALL for debugging
    val handlers:Rail[Handler] = Java.convert[Handler]( logger.getParent().getHandlers() );
    for( handler in handlers ) {
      handler.setLevel( logger.getLevel() );
    }

    val refTableSearcher = new GlobalRef[PairTablesSearchEngine](
      new PairTablesSearchEngine( new Tables( seed ), engine )
    );

    logger.info("Creating initial tasks");
    val newTasks = at( refTableSearcher ) {
      val tasks = refTableSearcher().searcher.createInitialTask( refTableSearcher().tables, Simulator.searchRegion() );
      return tasks;
    };
    val init = () => { return new JobQueue( refTableSearcher ); };
    val glb = new GLB[JobQueue, Long](init, GLBParameters.Default, true);

    logger.info("Staring GLB");
    val start = () => { glb.taskQueue().addInitialTasks( newTasks ); };
    val r = glb.run(start);
    logger.info("Finished GLB");

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
    val engine = new MockSearchEngine( 24, 120, 0.9, 5, 3.0, 0.0 );
    val seed = Long.parse( args(0) );
    m.run( seed, engine );
  }
}
