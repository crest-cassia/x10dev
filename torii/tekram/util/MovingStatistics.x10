package tekram.util;
import x10.util.ArrayList;
import x10.util.HashMap;
import x10.util.Map;
import x10.util.List;
import x10.util.Pair;
import x10.util.Random;
import tekram.util.Statistics;

/**
 * A data structure to compute moving statistics with iterative update.
 */
public class MovingStatistics {

	static class State {
		public var sum1:Double;
		public var sum2:Double;
		public var sumsq1:Double;
		public var sumsq2:Double;
		public var sumsqX:Double;
		public var size:Long;
		public var f:(Double)=>Double;
		public var t:Long;

		public def this(f:(Double)=>Double) {
			this.f = f;
		}

		public def this() {
			this(null);
		}
	}

	public var cache:Map[Pair[List[Double],List[Double]],Map[Long,State]];
	
	public def this() {
		this.cache = new HashMap[Pair[List[Double],List[Double]],Map[Long,State]]();
	}

	public def getKey(a:List[Double], b:List[Double]) = new Pair[List[Double],List[Double]](a, b);

	public def getState(a:List[Double], b:List[Double], size:Long):State {
		val key = this.getKey(a, b);
		return this.cache.get(key).get(size);
	}

	public def tick(a:List[Double], b:List[Double], size:Long):Long {
		return this.getState(a, b, size).t;
	}

	public def tick(a:List[Double], size:Long):Long {
		return this.tick(a, a, size);
	}

	public def exists(a:List[Double], b:List[Double], size:Long):Boolean {
		val cache = this.cache;
		val key = this.getKey(a, b);
		if (!cache.containsKey(key)) {
			return false;
		}
		val states = cache.get(key);
		if (!states.containsKey(size)) {
			return false;
		}
		return true;
	}

	public def exists(a:List[Double], size:Long):Boolean {
		return this.exists(a, a, size);
	}

	public def register(a:List[Double], b:List[Double], size:Long, f:(Double)=>Double) {
		assert a.size() == b.size() : "a.size() == b.size(): Currently not supported";
		val cache = this.cache;
		val key = this.getKey(a, b);
		if (!cache.containsKey(key)) {
			cache.put(key, new HashMap[Long,State]());
		}
		val states = cache.get(key);
		if (!states.containsKey(size)) {
			states.put(size, new State(f));
		}
		if (a.size() > 0 && b.size() > 0) {
			val s = states.get(size);
			val t1 = a.size() - 1;
			val t2 = b.size() - 1;
			val sub1 = a.subList(Math.max(t1 - size + 1, 0), t1 + 1);
			val sub2 = b.subList(Math.max(t2 - size + 1, 0), t2 + 1);
			if (f != null) {
				Statistics.map(sub1, f);
				Statistics.map(sub2, f);
			}
			s.sum1 = Statistics.sum(sub1);
			s.sum2 = Statistics.sum(sub2);
			s.sumsq1 = Statistics.sumofsquares(sub1);
			s.sumsq2 = Statistics.sumofsquares(sub2);
			s.sumsqX = Statistics.sumofproducts(sub1, sub2);
			s.size = Math.min(sub1.size(), sub2.size());
			s.t = Math.min(a.size(), b.size());
		}
	}

	public def register(a:List[Double], b:List[Double], size:Long) {
		this.register(a, b, size, null);
	}

	public def register(a:List[Double], size:Long, f:(Double)=>Double) {
		this.register(a, a, size, f);
	}

	public def register(a:List[Double], size:Long) {
		this.register(a, a, size, null);
	}

	public def update(a:List[Double], b:List[Double]) {
		assert a.size() == b.size() : "a.size() == b.size(): Currently not supported";
		val cache = this.cache;
		val key = this.getKey(a, b);
		val states = cache.get(key);
		for (size in states.keySet()) {
			val s = states.get(size);
			val f = (s.f != null ? s.f : (x:Double) => x);
			val t1 = a.size() - 1 - size;
			val t2 = b.size() - 1 - size;
			if (t1 < 0) {
				val latest1 = f(a.getLast());
				val latest2 = f(b.getLast());
				s.sum1 += latest1;
				s.sum2 += latest2;
				s.sumsq1 += latest1 * latest1;
				s.sumsq2 += latest2 * latest2;
				s.sumsqX += latest1 * latest2;
				s.size = Math.min(a.size(), b.size());
				s.t += 1;
			} else {
				val oldest1 = f(a(t1));
				val latest1 = f(a.getLast());
				val oldest2 = f(b(t2));
				val latest2 = f(b.getLast());
				s.sum1 -= oldest1;
				s.sum1 += latest1;
				s.sum2 -= oldest2;
				s.sum2 += latest2;
				s.sumsq1 -= oldest1 * oldest1;
				s.sumsq1 += latest1 * latest1;
				s.sumsq2 -= oldest2 * oldest2;
				s.sumsq2 += latest2 * latest2;
				s.sumsqX -= oldest1 * oldest2;
				s.sumsqX += latest1 * latest2;
				s.size = size;
				s.t += 1;
			}
		}
	}

	public def update(a:List[Double]) {
		this.update(a, a);
	}

	/**
	 * An implicit update for all registered pairs of time-series.
	 */
	public def update() {
		for (p in this.cache.keySet()) {
			this.update(p.first, p.second);
		}
	}

	public def sum(a:List[Double], size:Long):Double {
		val s = this.getState(a, a, size);
		return s.sum1;
	}

	public def sumofproducts(a:List[Double], b:List[Double], size:Long):Double {
		val s = this.getState(a, b, size);
		return s.sumsqX;
	}

	public def sumofsquares(a:List[Double], size:Long):Double {
		return sumofproducts(a, a, size);
	}

	public def mean(a:List[Double], size:Long):Double {
		val s = this.getState(a, a, size);
		return s.sum1 / s.size;
	}

	public def variance(a:List[Double], size:Long):Double {
		val s = this.getState(a, a, size);
		val m1 = s.sum1 / s.size;
		return s.sumsq1 / s.size - m1 * m1;
	}

	public def covariance(a:List[Double], b:List[Double], size:Long):Double {
		val s = this.getState(a, b, size);
		val m1 = s.sum1 / s.size;
		val m2 = s.sum2 / s.size;
		return s.sumsqX / s.size - m1 * m2;
	}

	public def corrcoef(a:List[Double], b:List[Double], size:Long):Double {
		val s = this.getState(a, b, size);
		val m1 = s.sum1 / s.size;
		val m2 = s.sum2 / s.size;
		val v1 = s.sumsq1 / s.size - m1 * m1;
		val v2 = s.sumsq2 / s.size - m2 * m2;
		val vX = s.sumsqX / s.size - m1 * m2;
		return vX / (Math.sqrt(v1) * Math.sqrt(v2));
	}

	public def regcoef(x:List[Double], y:List[Double], size:Long):Double {
		val s = this.getState(x, y, size);
		val m1 = s.sum1 / s.size;
		val m2 = s.sum2 / s.size;
		val v1 = s.sumsq1 / s.size - m1 * m1;
		val vX = s.sumsqX / s.size - m1 * m2;
		return vX / v1;
	}

	public def regression(x:List[Double], y:List[Double], size:Long):(Double)=>Double {
		val s = this.getState(x, y, size);
		val m1 = s.sum1 / s.size;
		val m2 = s.sum2 / s.size;
		val v1 = s.sumsq1 / s.size - m1 * m1;
		val vX = s.sumsqX / s.size - m1 * m2;
		return (z1:Double) => (vX / v1) * (z1 - m1) + m2;
	}

	public static def main(Rail[String]) {
		val random = new Random();
		val s = new MovingStatistics();
		val a0 = new ArrayList[Double]();
		val b0 = new ArrayList[Double]();

		// Step 0. Register.
		s.register(a0, 10);
		s.register(a0, 20);
		s.register(a0, b0, 10);
		for (i in 0..100) {
			// Step 1. A new observation.
			a0.add(random.nextDouble());
			b0.add(random.nextDouble());
			// Step 2. Update.
//			s.update(a0);
//			s.update(a0, b0);
			s.update();
			
			val a0_10 = a0.subList(Math.max(i - 10 + 1, 0), i + 1);
			val b0_10 = b0.subList(Math.max(i - 10 + 1, 0), i + 1);
			val a0_20 = a0.subList(Math.max(i - 20 + 1, 0), i + 1);
			Console.OUT.println(["sum: ", s.sum(a0, 10), Statistics.sum(a0_10)]);
			Console.OUT.println(["sum: ", s.sum(a0, 20), Statistics.sum(a0_20)]);

			Console.OUT.println(["mean: ", s.mean(a0, 10), Statistics.mean(a0_10)]);
			Console.OUT.println(["variance: ", s.variance(a0, 10), Statistics.variance(a0_10)]);
			Console.OUT.println(["sumofsquares: ", s.sumofsquares(a0, 10), Statistics.sumofsquares(a0_10)]);

			Console.OUT.println(["covariance: ", s.covariance(a0, b0, 10), Statistics.covariance(a0_10, b0_10)]);
			Console.OUT.println(["sumofproducts: ", s.sumofproducts(a0, b0, 10), Statistics.sumofproducts(a0_10, b0_10)]);
			Console.OUT.println(["corrcoef: ", s.corrcoef(a0, b0, 10), Statistics.corrcoef(a0_10, b0_10)]);
			Console.OUT.println(["regcoef: ", s.regcoef(a0, b0, 10), Statistics.regcoef(a0_10, b0_10)]);
		}

		val s1 = new MovingStatistics();
		s1.register(a0, 10);
		Console.OUT.println([s1.tick(a0, 10), s.mean(a0, 10), s1.mean(a0, 10)]);
		a0.add(random.nextDouble());
		s.update(a0);
		s1.update(a0);
		Console.OUT.println([s1.tick(a0, 10), s.mean(a0, 10), s1.mean(a0, 10)]);

	}
}
