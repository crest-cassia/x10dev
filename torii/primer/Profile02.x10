import x10.compiler.Profile;

public class Profile02 {

	public static def main(Rail[String]) {

		val N_PLACES = Place.numPlaces();

		val profs = new Rail[Runtime.Profile](N_PLACES, (i:Long) => new Runtime.Profile());
		val places = Place.places();
		val prof0 = profs(0);

		finish {
			for (p in 0..(N_PLACES - 1)) {
				val z = 1;
				// COMPILE ERROR!!  Cannot we use multiple Profiles?
				async @Profile(profs(p)) at (places(p)) {
					var i:Long = 0;
					for (0..100) {
						i += z;
					}
				}
			}
		}
		for (prof in profs) {
			Console.OUT.println("bytes (number of bytes that were serialized): " + prof.bytes);
			Console.OUT.println("communicationNanos (time spent sending the message): " + prof.communicationNanos);
			Console.OUT.println("serializationNanos (time spent serializing): " + prof.serializationNanos);
		}
	}
}
