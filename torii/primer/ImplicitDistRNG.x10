import x10.util.Random;

public class ImplicitDistRNG {

	static class XorShiftRandom {
		var x:UInt = 123456789un;
		var y:UInt = 362436069un;
		var z:UInt = 521288629un;
		var w:UInt = 88675123un;
		var s:UInt; // Just to memorize

		public def getSeed():UInt = this.s;

		public def setSeed(s:UInt) {
			this.w = s;
			this.s = s;
		}

		public def nextUInt():UInt {
			val t:UInt;
			t = x ^ (x << 11);
			x = y; y = z; z = w;
			w = w ^ (w >> 19) ^ (t ^ (t >> 8));
			return w;
		}
	}

	// ImpENG that generates all the seed of child RNGs.
	// This must have its own RNG algorithm, instead of x10.util.Random,
	// because (1) the seed is allowed to set at the instanciation;
	//         (2) X10 doesn't allow ``static variables``.
	// The alt algorithm must permit to set the seed leter.
	static class ImpENG extends XorShiftRandom {
	}

	// What users actually see is this.
	static class ExpRNG extends x10.util.Random {
		static ROOT = new ImpENG(); // All ExpRNG must be derived from this.

		public def this() {
			super(ROOT.nextUInt()); // Pass a newly generated seed IMPLICITLY.
		}
	}

	public static def main(args:Rail[String]) {
		var seed:Long = 1;
		if (args.size > 0) {
			seed = Long.parse(args(0));
		}

		Console.OUT.println("# numPlaces() " + Place.numPlaces());
		Console.OUT.println("# seed " + seed);

		// Show the initial values
		for (p in Place.places()) {
			at (p) {
				Console.OUT.println(p + " initial: " + ExpRNG.ROOT.getSeed());
			}
		}

		// THE system-wide/global root RNG.
		val SYSRNG = new Random(seed);
		for (p in Place.places()) {
			// Generate a random number rooted from SYSRNG.
			val lseed = SYSRNG.nextInt(Int.MAX_VALUE) as UInt;
			at (p) {
				/** ** (1) ** **/
				// Set the seed of ``place-wise/local static`` RNG
				ExpRNG.ROOT.setSeed(lseed);
				Console.OUT.println(p + " setseed: " + ExpRNG.ROOT.getSeed());
			}
		}

		for (p in Place.places()) {
			at (p) {
				Console.OUT.println(p + " preserved?: " + ExpRNG.ROOT.getSeed());
				val x = new ExpRNG();
				Console.OUT.println(p + " inherited?: " + x.ROOT.getSeed());
			}
		}

		for (p in Place.places()) {
			at (p) {
				/** ** (2) ** **/
				val x = new ExpRNG();
				for (t in 1..10) {
					Console.OUT.println(p + ": " + x.nextLong(10));
				}
			}
		}
	}
}
