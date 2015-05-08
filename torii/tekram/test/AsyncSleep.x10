
public class AsyncSleep {

	static class HeavyJob(id:Long) {

		public def this(id:Long) {
			property(id);
		}

		public def run(sleepTime:Long) {
			Console.OUT.println("SLEEP " + this.id);
			System.threadSleep(sleepTime);
			Console.OUT.println("WAKE  " + this.id);
		}
	}

	public static def main(args:Rail[String]) {

		Console.OUT.println("WARNING: export X10_NTHREADS and X10_NPLACES");

		val X10_NTHREADS = System.getenv("X10_NTHREADS");
		val X10_NPLACES = System.getenv("X10_NPLACES");
		val NUM_PLACES = Place.numPlaces();

		Console.OUT.println(["X10_NTHREADS", X10_NTHREADS]);
		Console.OUT.println(["X10_NPLACES", X10_NPLACES]);
		Console.OUT.println(["numPlaces()", NUM_PLACES]);

		val numJobs = 4;
		val jobs = new Rail[HeavyJob](numJobs, (i:Long) => new HeavyJob(i));

		val begin = System.nanoTime();
		Console.OUT.println("START");
		finish {
			for (var i:Long = 0; i < numJobs; i++) {
				val p = Place.places()(i % NUM_PLACES);
				val j = jobs(i);
				Console.OUT.println("ASYNC "+ j.id);
				async at (p) {
					j.run(5000);
				}
			}
		}
		val end = System.nanoTime();
		Console.OUT.println("FINISH");
		Console.OUT.println("TOTAL: " + ((end - begin) / 1000000) + "msec");
	}
}
