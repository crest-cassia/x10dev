import x10.util.Indexed;
import x10.util.List;
import x10.util.ArrayList;

public class Fun01 {

	static class X implements (Long)=>Long {

		public operator this(i:Long):Long = i;
	}

	public static def print(a:(Long)=>Long, start:Long, end:Long) {
		for (i in start..end) {
			Console.OUT.print(a(i) + " ");
		}
		Console.OUT.println();
	}

	public static def main(Rail[String]) {
		val l:List[Long] = new ArrayList[Long]();
		l.add(6);
		l.add(7);
		l.add(8);
		val c = l as Indexed[Long];

		val a = new Rail[Long](3);
		a(0) = 3;
		a(1) = 4;
		a(2) = 5;

		val x = new X();

		print(l, 0, 2); // COMPILE ERROR: Unable to find unique starting function type for upcast
		print(c, 0, 2); // OK
		print(a, 0, 2);
		print(x, 0, 2);
	}
}
