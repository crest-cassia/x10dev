import x10.util.ArrayList;
import x10.util.List;
import x10.util.Ordered;
import x10.compiler.*;
import x10.util.RailUtils;

public class LU {

	public static def map[T,U](a:List[T], f:(T)=>U):List[U] {
		val b = new ArrayList[U]();
		for (x in a) {
			b.add(f(x));
		}
		return b;
	}

	public static def reduce[T,U](a:List[T], f:(U, T)=>U, e:U):U {
		var y:U = e;
		for (x in a) {
			y = f(y, x);
		}
		return y;
	}

	public static def sum[T,U](a:List[T], f:(T)=>U){U <: Arithmetic[U], U haszero}:U {
		return reduce(a, (y:U, x:T) => y + f(x), Zero.get[U]());
	}

	public static def sum[T](a:List[T]){T <: Arithmetic[T], T haszero}:T {
		return sum(a, (x:T) => x as T);
	}

	public static def sum[T](a:Rail[T]){T <: Arithmetic[T], T haszero}:T {
		return RailUtils.reduce(a, (x:T, y:T) => x + y, Zero.get[T]());
	}

	private static class X {
		var i:Long;
		public def this(i:Long) { this.i = i; }
		public def toString() = "X{i=" + i + "}";
	}

	public static def main(Rail[String]) {

		val a = new ArrayList[X]();
		val b = new ArrayList[Long]();
		for (i in 0..9) {
			a.add(new X(i));
			b.add(i);
		}

		for (i in 0..9) {
			Console.OUT.println("a(" + i + ") = " + a(i));
		}

		Console.OUT.println("> sum(a, (x:X) => x.i)");
		Console.OUT.println(   sum(a, (x:X) => x.i) );

		Console.OUT.println("> sum(b)");
		Console.OUT.println(   sum(b) );

		Console.OUT.println("> sum(map(a, (x:X) => x.i))");
		Console.OUT.println(   sum(map(a, (x:X) => x.i)) ); // X10 is hard-headed!!
		Console.OUT.println(   sum(map(a, (x:X):Long => x.i)) ); // OK
		Console.OUT.println(   sum(map[X,Long](a, (x:X) => x.i)) ); // OKAY
		Console.OUT.println(   sum(map(a, (x:X) => x.i) as List[Long]) ); // OKAY BUT X10 IS UGLY

//		val u = a.toRail();
//		val r = b.toRail();
//		Console.OUT.println(   sum(RailUtils.map(u, new Rail[Long](u.size), (x:X) => x.i)));
//		Console.OUT.println(   sum(RailUtils.map(u, new Rail[Long](u.size), (x:X):Long => x.i)));
	}
}
