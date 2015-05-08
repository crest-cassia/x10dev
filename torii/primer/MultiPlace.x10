
public class MultiPlace {

	public static def main(Rail[String]) {
		
		val NUM_PLACES = Place.numPlaces();

		val places = Place.places();

		Console.OUT.println("======== Test 0 ========");
		Console.OUT.println("numPlaces: " + NUM_PLACES);
		for (p in places) at (p) {
			Console.OUT.println(["p.id: " + p.id, " here.id: " + here.id, " home().id: " + Runtime.home().id, " hostname: " + Runtime.getName()]);
		}

		Console.OUT.println("======== Test 1 ========");
		Console.OUT.println("numPlaces: " + NUM_PLACES);
		finish for (p in Place.places()) async at (p) {
			Console.OUT.println(["p.id: " + p.id, " here.id: " + here.id, " home().id: " + Runtime.home().id, " hostname: " + Runtime.getName()]);
		}

		Console.OUT.println("======== Test 2 ========");
		Console.OUT.println("numPlaces: " + NUM_PLACES);
		finish for (p in places) async at (p) {
			Console.OUT.println(["p.id: " + p.id, " here.id: " + here.id, " home().id: " + Runtime.home().id, " hostname: " + Runtime.getName()]);
		}

		Console.OUT.println("======== Test 3 ========");
		Console.OUT.println("numPlaces: " + NUM_PLACES);
		finish for (i in 0..(NUM_PLACES - 1)) {
			val p = places(i);
			async at (p) {
				atomic Console.OUT.println(["p.id: " + p.id, " here.id: " + here.id, " home().id: " + Runtime.home().id, " hostname: " + Runtime.getName()]);
			}
		}

		Console.OUT.println("======== Test 4 ========");
		Console.OUT.println("numPlaces: " + NUM_PLACES);
		finish {
			for (i in 0..(NUM_PLACES - 1)) {
				val p = places(i);
				async at (p) {
					Console.OUT.println(["p.id: " + p.id, " here.id: " + here.id, " home().id: " + Runtime.home().id, " hostname: " + Runtime.getName()]);
				}
			}
		}
	}
}
