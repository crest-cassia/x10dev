import x10.util.ArrayList;
import x10.io.File;
// import x10.interop.Java;
// import java.util.logging.Logger;
// import java.util.logging.Level;
// import java.util.logging.Handler;

class Mock {

  def run( seed: Long, engine: SearchEngineI ): void {
    // val logger = Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);
    // logger.setLevel(Level.INFO);   // set Level.ALL for debugging
    // val handlers:Rail[Handler] = Java.convert[Handler]( logger.getParent().getHandlers() );
    // for( handler in handlers ) {
    //   handler.setLevel( logger.getLevel() );
    // }

    val modBuf = 4;
    val numBuffers = Place.numPlaces() / modBuf;

    val refJobProducer = new GlobalRef[JobProducer](
      new JobProducer( new Tables(seed), engine, numBuffers )
    );

    finish for( i in 0..((Place.numPlaces()-1)/modBuf) ) {
      async at( Place(i*modBuf) ) {
        val buffer = new JobBuffer( refJobProducer );
        buffer.getInitialTasks();
        val refBuffer = new GlobalRef[JobBuffer]( buffer );

        val min = Runtime.hereLong();
        val max = Math.min( min+modBuf, Place.numPlaces() );
        for( j in (min+1)..(max-1) ) {
          async at( Place(j) ) {
            val consumer = new JobConsumer( refBuffer );
            consumer.run();
          }
        }
      }
    }

    at( refJobProducer ) {
      refJobProducer().printJSON("parameter_sets.json", "runs.json");
    }
  }

  static public def main( args: Rail[String] ) {
    val m = new Mock();
    val engine = new MockSearchEngine( 8, 8, 0.25, 4, 1.0, 0.0 );
    val seed = Long.parse( args(0) );
    m.run( seed, engine );
  }
}

