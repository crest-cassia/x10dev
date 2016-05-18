package samples.Option;
import x10.util.ArrayList;
import x10.util.List;
import x10.util.Ordered;

public class ListUtils {

	public static def map[T,U](a:List[T], f:(T)=>U):List[U] {
		val b = new ArrayList[U]();
		for (x in a) {
			b.add(f(x));
		}
		return b;
	}

	public static def filter[T](a:List[T], p:(T)=>Boolean):List[T] {
		val b = new ArrayList[T]();
		b.addAllWhere(a, p);
		return b;
	}

	public static def reduce[T,U](a:List[T], f:(U, T)=>U, e:U):U {
		var y:U = e;
		for (x in a) {
			y = f(y, x);
		}
		return y;
	}

	public static def reduce[T](a:List[T], f:(T, T)=>T):T {
		var y:T = a(0);
		for (i in 1..(a.size() - 1)) {
			y = f(y, a(i));
		}
		return y;
	}

	public static def sum[T,U](a:List[T], f:(T)=>U){U <: Arithmetic[U], U haszero}:U {
		return reduce(a, (y:U, x:T):U => y + f(x), Zero.get[U]());
	}

	public static def sum[T](a:List[T]){T <: Arithmetic[T], T haszero}:T {
		return sum(a, (x:T):T => x);
	}

	public static def max[T,U](a:List[T], f:(T)=>U){U <: Ordered[U]}:T {
		return reduce(a, (x:T, y:T):T => f(x) > f(y) ? x : y);
	}

	public static def max[T](a:List[T]){T <: Ordered[T]}:T {
		return max(a, (x:T):T => x);
	}

	public static def min[T,U](a:List[T], f:(T)=>U){U <: Ordered[U]}:T {
		return reduce(a, (x:T, y:T):T => f(x) < f(y) ? x : y);
	}

	public static def min[T](a:List[T]){T <: Ordered[T]}:T {
		return min(a, (x:T):T => x);
	}

	public static def binarySearch[T](a:List[T], x:T){T <: Arithmetic[T], T <: Ordered[T], T <: Comparable[T]}:Long {
		return (a as ArrayList[T]).binarySearch(x);
	}

	public static def binarySearchNearest[T](a:List[T], x:T){T <: Arithmetic[T], T <: Ordered[T], T <: Comparable[T]}:Long {
		val n = a.size();
		val j = binarySearch(a, x);
		val i = (j >= 0) ? j : -j - 1; // Insertion point
		if (i <= 0) return 0;
		if (i >= n - 1) return n - 1;
		return (x - a(i - 1) < a(i) - x) ? i - 1 : i;    // a(i - 1) <= x <= a(i)
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

		Console.OUT.println("> map(a, (x:X) => x.i)");
		Console.OUT.println(   map(a, (x:X) => x.i) );

		Console.OUT.println("> filter(a, (x:X) => x.i < 5)");
		Console.OUT.println(   filter(a, (x:X) => x.i < 5) );

		Console.OUT.println("> reduce(a, (y:Long, x:X) => y + x.i, 0)");
		Console.OUT.println(   reduce(a, (y:Long, x:X) => y + x.i, 0) );

		Console.OUT.println("> reduce(b, (y:Long, x:Long) => y + x)");
		Console.OUT.println(   reduce(b, (y:Long, x:Long) => y + x) );

		Console.OUT.println("> sum(a, (x:X) => x.i)");
		Console.OUT.println(   sum(a, (x:X) => x.i) );

		Console.OUT.println("> sum(b)");
		Console.OUT.println(   sum(b) );

		Console.OUT.println("> max(a, (x:X) => x.i)");
		Console.OUT.println(   max(a, (x:X) => x.i) );

		Console.OUT.println("> max(b)");
		Console.OUT.println(   max(b) );

		Console.OUT.println("> min(a, (x:X) => x.i)");
		Console.OUT.println(   min(a, (x:X) => x.i) );

		Console.OUT.println("> min(b)");
		Console.OUT.println(   min(b) );

		Console.OUT.println("> MISC");
		Console.OUT.println(   filter(map(a, (x:X) => x.i), (i:Long) => i < 5) );
		//Console.OUT.println(   sum(map(a, (x:X) => x.i)) ); // X10 is hard-headed!!
		Console.OUT.println(   sum(map(a, (x:X) => x.i) as List[Long]) ); // X10 is hard-headed!!
		Console.OUT.println(   max(filter(a, (x:X) => x.i < 5), (x:X) => x.i) );

	}
}
