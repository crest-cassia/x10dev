class KumpulaSearch {

  static public def main( args: Rail[String] ) {
    val m = new Main();
    val engine = new GridSearcher();
    // val engine = new MockSearchEngine( numStaticTasks, 0, 0.25, 4, sleepMu, sleepSigma );
    val seed = Long.parse( args(0) );
    m.run( seed, engine );
  }
}
