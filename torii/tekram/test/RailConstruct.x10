package tekram.test;

public class RailConstruct {

	public static def f(Rail[Long]) {
	}

	public static def g(Rail[Rail[Long]]) {
	}

	public static def main(Rail[String]) {
		val a = [
			[1,2,3],
			[4,5,6]
		];
		Console.OUT.println(a.typeName());
		Console.OUT.println(a);
		f(a(1));
//		g(a); // DOESN'T WORK.


		val b = new Rail[Rail[Long]](2);
		b(0) = new Rail[Long]([1, 2, 3]);
		b(1) = new Rail[Long]([4, 5, 6]);
		Console.OUT.println(b.typeName());
		Console.OUT.println(b);
		f(b(1));
		g(b);


		// DOESN'T WORK.
//		val c = new Rail[Rail[Long]]([
//				[1,2,3],
//				[4,5,6]
//			]);


		// THIS WORKS.
		val d = new Rail[Rail[Long]](2);
		d(0) = [1, 2, 3];
		d(1) = [4, 5, 6];
		Console.OUT.println(d.typeName());
		Console.OUT.println(d);
		f(d(1));
		g(d);

	}
}
