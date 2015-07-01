import x10.compiler.Profile;

public class Profile03 {

	public static def main(Rail[String]) {

		val gprof = new Runtime.Profile();
		val prof = new Runtime.Profile();

		@Profile(gprof)
		finish {
			val i = 0;
			for (0..100) {
				@Profile(prof)
				at (here) async {
					var k:Long = 0;
					k += i;
				}
			}
		}
		Console.OUT.println("bytes (number of bytes that were serialized): " + prof.bytes);
		Console.OUT.println("communicationNanos (time spent sending the message): " + prof.communicationNanos);
		Console.OUT.println("serializationNanos (time spent serializing): " + prof.serializationNanos);

		Console.OUT.println("bytes (number of bytes that were serialized): " + gprof.bytes);
		Console.OUT.println("communicationNanos (time spent sending the message): " + gprof.communicationNanos);
		Console.OUT.println("serializationNanos (time spent serializing): " + gprof.serializationNanos);

	}
}
