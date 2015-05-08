import x10.util.List;
import x10.util.ArrayList;

public struct ListAddReducer[T] implements Reducible[List[T]] {

	public def zero():List[T] = new ArrayList[T]();

	public operator this(a:List[T], b:List[T]):List[T] {
		if (a != b) {
			//Console.OUT.println(["a", a]);
			//Console.OUT.println(["b", b]);
			a.addAll(b);
		}
		return a;
	}

	static struct MySumReducer implements Reducible[Long] {
		public def zero():Long = 10;
		public operator this(a:Long, b:Long):Long = a + b;
	}

	public static def main(args:Rail[String]) {

		val z = finish (Reducible.SumReducer[Long]()) {
			for (i in 1..10) {
				async offer i;
			}
		};
		val y = finish (MySumReducer()) {
			for (i in 1..10) {
				async offer i;
			}
		};
		Console.OUT.println([z, y]);

		val a = finish (ListAddReducer[Long]()) {
			for (i in 1..5) {
				async {
					val x = new ArrayList[Long]();
					x.add(1);
					x.add(2);
					offer x;
				}
			}
		};
		Console.OUT.println(a);
	}
}
