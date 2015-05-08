
public class PlaceLocalHandle01 {

	public static def main(args:Rail[String]) {

		val plh = PlaceLocalHandle.make[Cell[Long]](Place.places(), () => new Cell[Long](0));

		for (p in Place.places()) {
			at (p) {
				plh().set(p.id);
				Console.OUT.println([p.id]);
			}
		}

		for (p in Place.places()) {
			at (p) {
				Console.OUT.println([p.id, plh()]);
			}
		}
	}
}
