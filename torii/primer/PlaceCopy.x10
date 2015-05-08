import x10.util.HashMap;

public class PlaceCopy {

	public static def main(args:Rail[String]) {
		
		val N_PLACES = Place.numPlaces();
		Console.OUT.println("# N_PLACES " + N_PLACES);

		val x = new Cell[Long](0);
		Console.OUT.println(["ORIG", x, x.hashCode()]);
		x.set(9);
		Console.OUT.println(["ORIG", x, x.hashCode()]);

		val h = new HashMap[Cell[Long],Long]();
		h.put(x, 7);

		for (p in Place.places()) {
			at (p) {
				x.set(p.id);
				Console.OUT.println([p.id, x, x.hashCode()]);
				Console.OUT.println(h(x));
			}
		}

		for (p in Place.places()) {
			at (p) {
				Console.OUT.println([p.id, x, x.hashCode()]);
				Console.OUT.println(h(x));
			}
		}
	}
}
