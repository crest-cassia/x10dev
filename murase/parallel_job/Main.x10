import x10.io.Console;
import x10.util.HashMap;
import x10.glb.GLBParameters;
import x10.glb.GLB;
import x10.util.Pair;
import x10.util.HashMap;
import x10.util.ArrayList;
import x10.io.File;
// import x10.interop.Java;
// import java.util.logging.Logger;
// import java.util.logging.Level;
// import java.util.logging.Handler;

class Main {

  def run( seed: Long, engine: SearchEngineI ): void {
    // val logger = Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);
    // logger.setLevel(Level.INFO);   // set Level.ALL for debugging
    // val handlers:Rail[Handler] = Java.convert[Handler]( logger.getParent().getHandlers() );
    // for( handler in handlers ) {
    //   handler.setLevel( logger.getLevel() );
    // }

    val refJobProducer = new GlobalRef[JobProducer](
      new JobProducer( new Tables(seed), engine )
    );

    val modBuf = 96;
    finish for( i in 0..((Place.numPlaces()-1)/modBuf) ) {
      async at( Place(i*modBuf) ) {
        val min = Runtime.hereLong();
        val max = Math.min( min+modBuf, Place.numPlaces() );
        for( j in min..(max-1) ) {
          if( j == 0 ) { continue; }
          async at( Place(j) ) {
            val consumer = new JobConsumer( refJobProducer );
            consumer.run();
          }
        }
      }
    }

    at( refJobProducer ) {
      refJobProducer().printJSON("parameter_sets.json", "runs.json");
    }
  }
}
