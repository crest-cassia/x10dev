import x10.util.ArrayList;
import x10.util.List;
import x10.util.concurrent.AtomicReference;

public class AsyncMerge {

	static class HeavyJob(id:Long) {

		public def this(id:Long) {
			property(id);
		}

		public def run() {
			Console.OUT.println("SLEEP " + this.id);
			System.threadSleep(0);
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

		val numJobs = 100;
		val jobs = new Rail[HeavyJob](numJobs, (i:Long) => new HeavyJob(i));
		val list = new ArrayList[Long]();

		val begin = System.nanoTime();
		Console.OUT.println("START");
		val listRef = new AtomicReference[List[Long]](list);
		val listArr = new Rail[Long](numJobs);
		finish {
			for (var i:Long = 0; i < numJobs; i++) {
				val p = Place.places()(i % NUM_PLACES);
				val k = i;
				val j = jobs(k);
				async at (p) {
					Console.OUT.println("ASYNC "+ j.id);
					j.run();
					//list.add(j.id);
					//atomic list.add(j.id);
					//listRef.get().add(j.id);
					//listArr(k) = j.id; // This doesn't work if using `at (p)`.
				}
			}
		}
		val end = System.nanoTime();
		Console.OUT.println("FINISH");
		Console.OUT.println("TOTAL: " + ((end - begin) / 1000000) + "msec");
		for (a in list) {
			Console.OUT.println(a);
		}
		for (i in listArr) {
			Console.OUT.println(listArr(i));
		}
	}
}
