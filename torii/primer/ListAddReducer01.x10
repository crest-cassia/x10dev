import x10.util.List;
import x10.util.ArrayList;

public class ListAddReducer01 {

	static struct ListAddReducer1[T] implements Reducible[List[T]] {

		public def zero():List[T] = new ArrayList[T]();

		public operator this(a:List[T], b:List[T]):List[T] {
			if (a != b) {
				a.addAll(b);
			}
			return a;
		}
	}

	static struct ListAddReducer2[T] implements Reducible[List[T]] {

		public def zero():List[T] = new ArrayList[T]();

		public operator this(a:List[T], b:List[T]):List[T] {
			val c = zero();
			c.addAll(a);
			c.addAll(b);
			return c;
		}
	}

	static struct ListAddReducer3[T] implements Reducible[List[T]] {

		public def zero():List[T] = null;

		public operator this(a:List[T], b:List[T]):List[T] {
			if (a == null) {
				return b;
			}
			if (b == null) {
				return a;
			}
			a.addAll(b);
			return a;
		}
	}

	static struct MySumReducer implements Reducible[Long] {
		public def zero():Long = 0;
		public operator this(a:Long, b:Long):Long = a + b;
	}


	public static def test(create:()=>Reducible[List[Long]], name:String, N_SAMPLES:Long) {
		var _begin:Long;

		_begin = System.nanoTime();
		for (1..N_SAMPLES) {
			val a = finish (ListAddReducer[Long]()) {
				for (i in 1..Place.numPlaces()) {
					async {
						val x = new ArrayList[Long]();
						x.add(1);
						x.add(2);
						offer x;
					}
				}
			};
		}
		Console.OUT.println(name + " multithread: " + (System.nanoTime() - _begin) / N_SAMPLES);

		_begin = System.nanoTime();
		for (1..N_SAMPLES) {
			val b = finish (ListAddReducer[Long]()) {
				for (p in Place.places()) {
					async at (p) {
						val x = new ArrayList[Long]();
						x.add(1);
						x.add(2);
						offer x;
					}
				}
			};
		}
		Console.OUT.println(name + " multiplace : " + (System.nanoTime() - _begin) / N_SAMPLES);

		_begin = System.nanoTime();
		for (1..N_SAMPLES) {
			val a = new ArrayList[Long]();
			val g = new GlobalRef[List[Long]](a);
			finish {
				for (p in Place.places()) {
					async at (p) {
						val x = new ArrayList[Long]();
						x.add(1);
						x.add(2);
						at (g.home) {
							atomic g().addAll(x);
						}
					}
				}
			}
		}
		Console.OUT.println(name + " atomic     : " + (System.nanoTime() - _begin) / N_SAMPLES);

	}

	public static def main(args:Rail[String]) {
		var N_SAMPLES:Long = 1000;
		if (args.size > 0) {
			N_SAMPLES = Long.parse(args(0));
		}

		test(() => new ListAddReducer1[Long](), "ListAddReducer1", N_SAMPLES);
		test(() => new ListAddReducer2[Long](), "ListAddReducer2", N_SAMPLES);
		test(() => new ListAddReducer3[Long](), "ListAddReducer3", N_SAMPLES);
		test(() => new ListAddReducer1[Long](), "ListAddReducer1", N_SAMPLES);
		test(() => new ListAddReducer2[Long](), "ListAddReducer2", N_SAMPLES);
		test(() => new ListAddReducer3[Long](), "ListAddReducer3", N_SAMPLES);
	}
}
