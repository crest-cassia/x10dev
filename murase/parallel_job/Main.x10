import x10.io.Console;
import x10.util.HashMap;
import x10.glb.GLBParameters;
import x10.glb.GLB;
import x10.util.HashMap;
import x10.util.ArrayList;

class Main {

  def run(): void {
    val refTables: GlobalRef[Tables] = new GlobalRef[Tables]( new Tables() );
    makeBox( refTables );
    val init = () => { return new MyTaskQueue( refTables ); };
    val glb = new GLB[MyTaskQueue, Long](init, GLBParameters.Default, true);

    Console.OUT.println("Starting ... ");
    val start = () => { glb.taskQueue().init(); };
    val r = glb.run(start);
    Console.OUT.println("r : " + r);

    at( refTables ) {
      // refTables().printRunsTable();
      Console.OUT.println( refTables().runsJson() );
    }
  }

  def makeBox( refTables: GlobalRef[Tables] ) {
    at( refTables ) {
      val box = refTables().createBox( 0.1, 0.2, -1.0, -0.6 );
    }
  }

  static public def main( args: Rail[String] ) {
    val m = new Main();
    m.run();
  }
}
