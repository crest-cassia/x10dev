import x10.util.ArrayList;

public class ArrayVsPointer {

	public static class X {

		public var i:Long;

		public def this(i:Long) {
			this.i = i;
		}

		public def get():Long {
			return 0;
		}
	}

	public static def main(Rail[String]) {

		val N = 100000;

		val a = new ArrayList[X]();
		for (i in 0..(N - 1)) {
			a.add(new X(i));
		}

		var sum:Long = 0;
		for (x in a) {
			sum += x.i;
		}

		val begin0 = System.nanoTime();
		for (x in a) {
			x.get();
		}
		val end0 = System.nanoTime();

		val begin1 = System.nanoTime();
		for (x in a) {
			a(x.i).get();
		}
		val end1 = System.nanoTime();

		val begin2 = System.nanoTime();
		for (x in a) {
			x.get();
		}
		val end2 = System.nanoTime();

		val begin3 = System.nanoTime();
		for (x in a) {
			a(x.i).get();
		}
		val end3 = System.nanoTime();

		Console.OUT.println("Pointer: " + (end0 - begin0));
		Console.OUT.println("Array  : " + (end1 - begin1));
		Console.OUT.println("Pointer: " + (end2 - begin2));
		Console.OUT.println("Array  : " + (end3 - begin3));
	}
}
