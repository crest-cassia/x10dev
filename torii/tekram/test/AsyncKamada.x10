import x10.util.Random;
import x10.util.ArrayList;
import x10.util.List;

public class AsyncKamada {

	static class X {
		
		public var a:Long;
		public var b:Double;

		public def this(a:Long, b:Double) {
			this.a = a;
			this.b = b;
		}
	}

	static class Job(id:Long) {

		public var loadTime:Long;
		public var jobType:Long;
		public static TYPE_SLEEP = 0;
		public static TYPE_INTEGRAL = 1;

		public def this(id:Long, jobType:Long, loadTime:Long) {
			property(id);
			this.jobType = jobType;
			this.loadTime = loadTime;
		}

		public def run() {
			if (this.jobType == TYPE_SLEEP) {
				Console.OUT.println("SLEEP " + this.id);
				System.threadSleep(this.loadTime);
				Console.OUT.println("WAKE  " + this.id);
			}
			if (this.jobType == TYPE_INTEGRAL) {
				val random = new Random();
				val beginTime = System.nanoTime();
				var sum:Double = 0.0;
				while ((System.nanoTime() - beginTime) < this.loadTime * 1e+6) {
					val d = random.nextDouble();
					sum += d;
				}
				Console.OUT.println("SUM " + sum + " " + this.id);
			}
		}

		public def get():List[X] {
			this.run();

			val a = new ArrayList[X]();
			val x = new X(0, 0.0);
			a.add(x);

			return a;
		}
	}


	public static def main(args:Rail[String]) {
		val X10_NTHREADS = System.getenv("X10_NTHREADS");
		val X10_NPLACES = System.getenv("X10_NPLACES");
		if (X10_NPLACES == null || X10_NTHREADS == null) {
			Console.OUT.println("WARNING: export X10_NTHREADS and X10_NPLACES");
		}

		Console.OUT.println("X10_NTHREADS " + String.valueOf(X10_NTHREADS));
		Console.OUT.println("X10_NPLACES " + String.valueOf(X10_NPLACES));

		if (args.size < 4) {
			throw new Exception("Usage: ./a.out #AGENTS JOB-TYPE JOB-LOAD ASYNC-TYPE");
		}

		val N_THREADS = Long.parse(X10_NTHREADS);
		val N = Long.parse(args(0));
		val JOB_TYPE = Long.parse(args(1));
		val LOAD_TIME = Long.parse(args(2));
		val ASYNC_TYPE = Long.parse(args(3));

		val jobs = new Rail[Job](N, (i:Long) => new Job(i, JOB_TYPE, LOAD_TIME));

		val begin = System.nanoTime();
		Console.OUT.println("START");

		if (ASYNC_TYPE == 0) {
			finish {
				//for (var tt:Long = 0; tt < N_THREADS; tt++) {
				//	val t = tt;
				for (t in 0..(N_THREADS - 1)) {
					async {
						for (var i:Long = t; i < N; i += N_THREADS) {
							val j = jobs(i);
							j.run();
						}
					}
				}
			}
		}
		if (ASYNC_TYPE == 1) {
			val A = new ArrayList[List[X]]();
			finish {
				//for (var tt:Long = 0; tt < N_THREADS; tt++) {
				//	val t = tt;
				for (t in 0..(N_THREADS - 1)) {
					async {
						val temp = new ArrayList[List[X]]();
						for (var i:Long = t; i < N; i += N_THREADS) {
							val j = jobs(i);
							val a = j.get();
							temp.add(a);
						}
						atomic A.addAll(temp);
					}
				}
			}
		}

		val end = System.nanoTime();
		Console.OUT.println("FINISH");
		Console.OUT.println("TIME " + ((end - begin) / 1e+9));
	}
}
