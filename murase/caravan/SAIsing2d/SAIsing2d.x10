import caravan.Main;
import caravan.SearchEngines.FileInputSearcher;

class SAIsing2d {

  static public def main( args: Rail[String] ) {
    val m = new Main();
    Console.ERR.println("Initializing Searcher");
    val engine = new FileInputSearcher();
    val seed = Long.parse( args(0) );
    Console.ERR.println("starting Main::run");
    m.run( engine, 300000, 500000, 4 );
  }
}
