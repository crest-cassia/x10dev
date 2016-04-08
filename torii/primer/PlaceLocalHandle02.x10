
public class PlaceLocalHandle02 {

	static class X {

		public def getENV():Cell[Long] {
			return null;
		}
	}

	static class XS extends X {

		public var ENV:Cell[Long];

		public def this() {
			this.ENV = new Cell[Long](0);
		}

		public def getENV():Cell[Long] {
			return this.ENV;
		}
	}

	static class XP extends X {

		public var ENV:PlaceLocalHandle[Cell[Long]];

		public def this() {
			this.ENV = PlaceLocalHandle.make[Cell[Long]](Place.places(), () => new Cell[Long](0));
		}

		public def getENV():Cell[Long] {
			return this.ENV();
		}
	}

	public static def main(args:Rail[String]) {

		val x:X;
		if (args.size == 0) {
			Console.OUT.println("XS");
			x = new XS();
		} else {
			Console.OUT.println("XP");
			x = new XP();
		}

		val v = 2;
		for (p in Place.places()) {
			at (p) {
				x.getENV().set(v);
				Console.OUT.println([p.id]);
			}
		}
	}
}
