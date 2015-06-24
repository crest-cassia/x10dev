class Mock {

  static public def main( args: Rail[String] ) {
    if( args.size == 3 ) {
      val m = new Main();
      val numStaticTasks = Long.parse( args(0) );
      val sleepMu = Double.parse( args(1) );
      val sleepSigma = Double.parse( args(2) );
      val engine = new MockSearchEngine( numStaticTasks, 0, 0.25, 4, sleepMu, sleepSigma );
      m.run( engine, 2000 );
    }
    else if( args.size == 5 ) {
      val m = new Main();
      val numStaticTasks = Long.parse( args(0) );
      val sleepMu = Double.parse( args(1) );
      val sleepSigma = Double.parse( args(2) );
      val psJson = args(3);
      val runJson = args(4);
      val engine = new MockSearchEngine( numStaticTasks, 0, 0.25, 4, sleepMu, sleepSigma );
      m.restart( psJson, runJson, engine, 2000 );
    }
    else {
      Console.ERR.println("Usage: ./a.out <numStaticTasks> <sleepMu> <sleepSigma> [psJSON] [runJSON]");
    }
  }
}
