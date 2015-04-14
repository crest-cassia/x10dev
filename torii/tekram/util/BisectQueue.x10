package tekram.util;
import x10.util.ArrayList;
import x10.util.List;
import x10.util.Random;

/**
 * An implementation of internal order-preserving array (queue).
 * The bisect algorithm is imported from Python 2.7.
 */
public class BisectQueue[T] {

	public var list:List[T];
	public var comparator:(T,T)=>Int;
	
	public def this(comparator:(T,T)=>Int) {
		this.list = new ArrayList[T]();
		this.comparator = comparator;
	}

	public def push(x:T) {
		val i = this.bisect(x);
		this.list.addBefore(i, x);
	}

	public def pop():T {
		val x = this.list.removeAt(0); // Tail-based array is probably better.
		return x;
	}

    public def peek():T = this.list(0);

	public def add(x:T) {
		this.push(x);
	}

	public def remove(x:T) {
		this.list.remove(x);
	}

	public def size() = this.list.size();

	public def contains(x:T) = this.list.contains(x);

	public def iterator() = this.list.iterator();

	public operator this(i:Long) = this.list(i);

	public def subList(begin:Long, end:Long) = this.list.subList(begin, end);

	public def bisect(x:T):Long {
		var lo:Long = 0;
		var hi:Long = this.list.size();

		while (lo < hi) {
			val mid = (lo + hi) / 2;
			val p = this.list(mid);
			val cmp = this.comparator(x, p);
			if (cmp < 0) {
				hi = mid;
			} else {
				lo = mid + 1;
			}
		}
		return lo;
	}

	public static def main(args:Rail[String]) {
		var last:Long;
		val random = new Random();

		// Test a min-heap.
		val h = new BisectQueue[Long]((x:Long, y:Long)=> Math.signum(x - y) as Int); // min-heap
		for (i in 0..10) {
			h.push(random.nextLong(10) - 5);
		}
		last = Long.MIN_VALUE;
		for (i in 0..10) {
			Console.OUT.println(h.list);
			val x = h.pop();
			Console.OUT.println(x);
			assert last <= x;
			last = x;
		}

		// Test a max-heap.
		val g = new BisectQueue[Long]((x:Long, y:Long)=> Math.signum(y - x) as Int); // max-heap
		for (i in 0..10) {
			g.push(random.nextLong(10) - 5);
		}
		last = Long.MAX_VALUE;
		for (i in 0..10) {
			Console.OUT.println(g.list);
			val x = g.pop();
			Console.OUT.println(x);
			assert last >= x;
			last = x;
		}

		// Test for the remove operation.
		val a = new BisectQueue[Long]((x:Long, y:Long)=> Math.signum(x - y) as Int);
		a.push(-5);
		a.push(0);
		a.push(0);
		a.push(+5);
		Console.OUT.println(a.list);
		a.remove(0);
		Console.OUT.println(a.list);
		a.remove(0);
		Console.OUT.println(a.list);
		a.remove(+5);
		Console.OUT.println(a.list);
		a.remove(-5);
		Console.OUT.println(a.list);
	}
}

