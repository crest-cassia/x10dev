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

    val refJobProducer = new GlobalRef[JobProducer](
      new JobProducer( new Tables(seed), engine )
    );

    finish for( place in Place.places() ) {
      if( place == here ) { continue; }
      async at( place ) {
        val consumer = new JobConsumer( refJobProducer );
        consumer.run();
      }
    }

    at( refJobProducer ) {
      refJobProducer().printJSON("parameter_sets.json", "runs.json");
    }
  }

  static public def main( args: Rail[String] ) {
    val m = new Mock();
    val engine = new MockSearchEngine( 8, 32, 0.0, 16, 2.0, 0.0 );
    val seed = Long.parse( args(0) );
    m.run( seed, engine );
  }
}
