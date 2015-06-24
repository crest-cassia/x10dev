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

  def run( engine: SearchEngineI, saveInterval: Long ): void {
    val table = new Tables();
    execute( table, engine, saveInterval );
  }

  def restart( psJson: String, runJson: String, engine: SearchEngineI, saveInterval: Long ) {
    val table = new Tables();
    table.load( psJson, runJson );
    execute( table, engine, saveInterval );
  }

  private def execute( table: Tables, engine: SearchEngineI, saveInterval: Long) {
    val modBuf = 4;
    val numBuffers = Place.numPlaces() / modBuf;

    val refJobProducer = new GlobalRef[JobProducer](
      new JobProducer( new Tables(), engine, numBuffers, saveInterval )
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
}
