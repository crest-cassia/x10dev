import x10.io.Console;
import x10.util.HashMap;
import x10.glb.GLBParameters;
import x10.glb.GLB;
import x10.util.Pair;
import x10.util.HashMap;
import x10.util.ArrayList;

class Main {

  def run(): void {
    val refTableSearcher =
      new GlobalRef[Cell[Pair[Tables,GridSearcher]]](
        new Pair[Tables,GridSearcher]( new Tables(), new GridSearcher() )
      );
    at( refTableSearcher ) {
      refTableSearcher()().second.makeBox( refTableSearcher()().first, 0.2, 0.3, -1.0, 1.0 );
    }
    val init = () => { return new MyTaskQueue( refTableSearcher ); };
    val glb = new GLB[MyTaskQueue, Long](init, GLBParameters.Default, true);

    Console.OUT.println("Starting ... ");
    val start = () => { glb.taskQueue().init(); };
    val r = glb.run(start);
    Console.OUT.println("r : " + r);

    at( refTableSearcher ) {
      Console.OUT.println( refTableSearcher()().first.runsJson() );
    }
  }

  static public def main( args: Rail[String] ) {
    val m = new Main();
    m.run();
  }
}
