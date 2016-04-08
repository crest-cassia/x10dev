import x10.util.Random;

public class ImplicitDistRNG02 {

	// ImpENG that generates all the seed of child RNGs.
	// This must have its own RNG algorithm, instead of x10.util.Random,
	// because (1) the seed is allowed to set at the instanciation;
	//         (2) X10 doesn't allow ``static variables``.
	// The alt algorithm must permit to set the seed leter.

	// What users actually see is this.
	static class ExpRNG {

		static ROOT = new Cell[Random](null); // All ExpRNG must be derived from this.

		var random:Random;
		
		public def this() {
			val seed = ROOT().nextLong(Long.MAX_VALUE / 2);
			this.random = new Random(seed); // Pass a newly generated seed IMPLICITLY.
		}
	}

	public static def main(args:Rail[String]) {
		var seed:Long = 1;
		if (args.size > 0) {
			seed = Long.parse(args(0));
		}

		Console.OUT.println("# numPlaces() " + Place.numPlaces());
		Console.OUT.println("# seed " + seed);

		// THE system-wide/global root RNG.
		val SYSRNG = new Random(seed);
		for (p in Place.places()) {
			// Generate a RNG rooted from SYSRNG.
			val random = SYSRNG.split();
			at (p) {
				/** ** (1) ** **/
				ExpRNG.ROOT.set(random);
			}
		}

		for (p in Place.places()) {
			at (p) {
				/** ** (2) ** **/
				val x = new ExpRNG();
				for (t in 1..10) {
					Console.OUT.println(p + ": " + x.random.nextLong(10));
				}
			}
		}
	}
}
