class Mock {

  static public def main( args: Rail[String] ) {
    val m = new Main();
    val numStaticTasks = Long.parse( args(0) );
    val sleepMu = Double.parse( args(1) );
    val sleepSigma = Double.parse( args(2) );
    val engine = new MockSearchEngine( numStaticTasks, 0, 0.25, 4, sleepMu, sleepSigma );
    m.run( engine, 2000 );
  }
}
