class IsingSearch {

  static public def main( args: Rail[String] ) {
    val m = new Main();
    val engine = new GridSearcher();
    val seed = Long.parse( args(0) );
    m.run( seed, engine );
  }
}
