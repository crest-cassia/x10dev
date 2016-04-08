import x10.util.List;
import x10.util.Pair;
import x10.util.ArrayList;

public class IndexedListAddReducer {

	static class ListAddReducer[T] implements Reducible[Pair[Long,Rail[List[T]]]] {

		public def zero():Pair[Long,Rail[List[T]]] = new Pair[Long,Rail[List[T]]](-2 as Long, new Rail[List[T]](N));

		public var N:Long;
		public var x:Pair[Long,Rail[List[T]]];

		public def this(N:Long) {
			this.N = N;
			this.x = new Pair[Long,Rail[List[T]]](-1, new Rail[List[T]](N));
		}

		public operator this(a:Pair[Long,Rail[List[T]]], b:Pair[Long,Rail[List[T]]]):Pair[Long,Rail[List[T]]] {
			Console.OUT.println(a.first + ", " + b.first);
			if (a.first >= 0) {
				val i = a.first;
				Console.OUT.println("a: " + a.second(i));
				x.second(i) = a.second(i);
			}
			if (b.first >= 0) {
				val i = b.first;
				Console.OUT.println("b: " + b.second(i));
				x.second(i) = b.second(i);
			}
			if (a.first <= -2) {
				for (i in 0..(N - 1)) {
					if (a.second(i) != null)
						x.second(i) = a.second(i);
				}
			}
			if (b.first <= -2) {
				for (i in 0..(N - 1)) {
					if (b.second(i) != null)
						x.second(i) = b.second(i);
				}
			}
			for (i in 0..(N - 1)) {
				 Console.OUT.println("x: " + x.second(i));
			}
			return x;
		}
	}

	public static def main(args:Rail[String]) {

		val N = Place.numPlaces();
		val x = finish (new ListAddReducer[Long](N)) {
			for (p in Place.places()) {
				async at (p) {
					val i = p.id;
					Console.OUT.println("From " + p + " of " + p.id);
					val r = new Rail[List[Long]](N);
					val a = new ArrayList[Long]();
					a.add(1);
					a.add(2);
					a.add(i);
					r(i) = a;
					offer new Pair[Long,Rail[List[Long]]](i, r);
				}
			}
		};
		Console.OUT.println(x.first);
		for (i in 0..(N - 1)) {
			Console.OUT.println(x.second(i));
		}
	}
}
