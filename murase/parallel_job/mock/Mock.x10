class Mock {

  static public def main( args: Rail[String] ) {
    if( args.size == 4 ) {
      val m = new Main();
      val numStaticTasks = Long.parse( args(0) );
      val sleepMu = Double.parse( args(1) );
      val sleepSigma = Double.parse( args(2) );
      val timeOut = Long.parse( args(3) ) * 1000;
      val engine = new MockSearchEngine( numStaticTasks, 0, 0.25, 4, sleepMu, sleepSigma );
      m.run( engine, 300000, timeOut );
    }
    else if( args.size == 6 ) {
      val m = new Main();
      val numStaticTasks = Long.parse( args(0) );
      val sleepMu = Double.parse( args(1) );
      val sleepSigma = Double.parse( args(2) );
      val timeOut = Long.parse( args(3) ) * 1000;
      val psJson = args(3);
      val runJson = args(4);
      val engine = new MockSearchEngine( numStaticTasks, 0, 0.25, 4, sleepMu, sleepSigma );
      m.restart( psJson, runJson, engine, 300000, timeOut );
    }
    else {
      Console.ERR.println("Usage: ./a.out <numStaticTasks> <sleepMu> <sleepSigma> <timeOut> [psJSON] [runJSON]");
    }
  }
}
