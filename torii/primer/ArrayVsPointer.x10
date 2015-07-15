import x10.util.ArrayList;
import x10.util.Random;

public class ArrayVsPointer {

	public static class X {

		public var i:Long;

		public def this(i:Long) {
			this.i = i;
		}

		public def get():Long {
			return this.i * 2;
		}
	}

	public static def main(Rail[String]) {

		val random = new Random();

		val N = 5000;

		val a = new ArrayList[X]();
		for (i in 0..(N - 1)) {
			a.add(new X(i));
		}
		val b = a.toRail();

		for (t in 1..1000) {

//			for (i in 0..(N - 1)) {
//				val j = random.nextLong(N);
//				val temp = a(i);
//				a(i) = a(j);
//				a(j) = temp;
//			}

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
				b(x.i).get();
			}
			val end2 = System.nanoTime();

//			Console.OUT.println("Pointer: " + (end0 - begin0));
//			Console.OUT.println("List   : " + (end1 - begin1));
//			Console.OUT.println("Rail   : " + (end2 - begin2));
			Console.OUT.println((end0 - begin0) + " " + (end1 - begin1) + " " + (end2 - begin2));
		}
	}
}
