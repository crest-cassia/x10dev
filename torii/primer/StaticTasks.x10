import x10.util.ArrayList;
import x10.glb.ArrayListTaskBag;
import x10.glb.TaskQueue;
import x10.glb.TaskBag;
import x10.glb.GLBParameters;
import x10.glb.GLB;
import x10.util.Team;
import x10.glb.Context;
import x10.glb.ContextI;
import x10.glb.GLBResult;

public class StaticTasks {

  class MyTaskQueue implements TaskQueue[MyTaskQueue, Long] {
    val tb = new ArrayListTaskBag[Long]();
    var results_of_current_worker:Long = 0;
    
    public def init(n: Long) {
      Console.OUT.println("adding " + n + " at " + here);
      for( i in 1..n ) {
        tb.bag().add(i);
      }
    }

    public def process(var n:Long, context: Context[MyTaskQueue,Long]):Boolean {

      for( var i:Long = 0; tb.size() > 0 && i < n; i++) {
        val x = tb.bag().removeLast();
        Console.OUT.println("running at " + here + " processing " + x);
        results_of_current_worker += x;
        context.yield();
      }
      return tb.bag().size() > 0;
    }

    public def count() {
      return 0;
    }

    public def merge( var _tb: TaskBag): void { 
      Console.OUT.println("MyTaskQueue#merge at " + here );
      tb.merge( _tb as ArrayListTaskBag[Long]);
    }
    
    public def split(): TaskBag {
      Console.OUT.println("MyTaskQueue#split at " + here);
      return tb.split();
    }

    public def printLog(): void {
      Console.OUT.println("MyTaskQueue#printLog at " + here);
    }

    public def getResult(): MyResult {
      Console.OUT.println("MyTaskQueue#getResult at " + here);
      return new MyResult(results_of_current_worker);
    }

    class MyResult extends GLBResult[Long] {
      val result: Long;

      public def this(local_result:Long) {
        Console.OUT.println("constructor of MyResult");
        result = local_result;
      }

      public def getResult():x10.lang.Rail[Long] {
        val r = new Rail[Long](1);
        r(0) = result;
        Console.OUT.println("MyResult#getResult at " + here + " : " + r );
        return r;
      }

      public def getReduceOperator():Int {
        return Team.ADD;
      }

      public def display(r:Rail[Long]):void {
        Console.OUT.println("MyResult#display: " + r(0));
      }
    }
  }

  def run(n: Long) {
    val init = () => { return new MyTaskQueue(); };
    val glb = new GLB[MyTaskQueue, Long](init, GLBParameters.Default, true);

    Console.OUT.println("Starting...");
    val start = () => { glb.taskQueue().init(n); };
    val r = glb.run(start);
    Console.OUT.println(r);
  }

  public static def main(args:Rail[String]) {
    val n = args.size < 1 ? 10 : Long.parseLong(args(0));
    val o = new StaticTasks();
    o.run(n);
  }
}
