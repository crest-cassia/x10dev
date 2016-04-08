
class RemoteCopyRef {

	static class A {
		var i:Long;
	}

	static class X {
		var a:A;
		var b:Long;
	}

	static class Y {
		var a:A;
		var b:Long;
	}

	public static def main(Rail[String]) {

		val N = Place.numPlaces();

		Console.OUT.println(N);
		
		val x = new X();
		val y = new Y();
		val a = new A();
		a.i = 90;
		x.a = a;
		y.a = a;
		Console.OUT.println(["x ", x.hashCode(), x.a.hashCode()]);
		Console.OUT.println(["y ", y.hashCode(), y.a.hashCode()]);
		Console.OUT.println(["a ", a.hashCode()]);
		Console.OUT.println(["* ", x.a.i, y.a.i, a.i]);

		at (Place(1)) {
			val x1 = x;
			val y1 = y;
			val a1 = a;
			a1.i += 1;
			Console.OUT.println(["x1 ", x1.hashCode(), x1.a.hashCode()]);
			Console.OUT.println(["y1 ", y1.hashCode(), y1.a.hashCode()]);
			Console.OUT.println(["a1 ", a1.hashCode()]);
			Console.OUT.println(["* ", x.a.i, y.a.i, a.i]);

			at (Place(2)) {
				val x2 = x1;
				val y2 = y1;
				val a2 = a1;
				a2.i += 1;
				Console.OUT.println(["x2 ", x2.hashCode(), x2.a.hashCode()]);
				Console.OUT.println(["y2 ", y2.hashCode(), y2.a.hashCode()]);
				Console.OUT.println(["a2 ", a2.hashCode()]);
				Console.OUT.println(["* ", x.a.i, y.a.i, a.i]);

				at (Place(0)) {
					val x0 = x2;
					val y0 = y2;
					val a0 = a2;
					a0.i += 1;
					Console.OUT.println(["x0 ", x0.hashCode(), x0.a.hashCode()]);
					Console.OUT.println(["y0 ", y0.hashCode(), y0.a.hashCode()]);
					Console.OUT.println(["a0 ", a0.hashCode()]);
					Console.OUT.println(["* ", x.a.i, y.a.i, a.i]);
				}
			}
		}
	}
}
