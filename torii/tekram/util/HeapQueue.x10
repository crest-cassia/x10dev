package tekram.util;
import x10.util.ArrayList;
import x10.util.List;
import x10.util.Random;


/**
 * A heap imported from java.util.PriorityQueue.
 * Use a comparator() to decide the priority of objects, and use the method
 * equals() to decide the identity of two objects.
 */
public class HeapQueue[T] implements Iterable[T] {

	public var heap:List[T];
	public var comparator:(T,T)=>Int;
	
	public def this(comparator:(T,T)=>Int) {
		this.heap = new ArrayList[T]();
		this.comparator = comparator;
	}

	static def PARENT(i:Long) = (i - 1) >>> 1;
	static def LEFT(i:Long)  = (i << 1) + 1;
	static def RIGHT(i:Long) = (i << 1) + 2;

	public def push(x:T) {
		val i = this.heap.size();
		this.siftup(i, x);
	}

	public def pop():T {
		val x = this.heap(0);
		val e = this.heap.removeLast();
		if (this.heap.size() > 0) {
			this.siftdown(0, e);
		}
		return x;
	}

    public def peek():T = this.heap(0);

	public def add(x:T) {
		this.push(x);
	}

	public def remove(x:T) {
		val i = this.heap.indexOf(x);
		val e = this.heap.removeLast();
		if (i < this.heap.size()) {
			this.siftdown(i, e);
			if (this.heap(i).equals(e)) {
				this.siftup(i, e);
			}
		}
	}

	public def size() = this.heap.size();

	public def contains(x:T) = this.heap.contains(x);

	/** An iterator of the underlying array, not sorted by priority. */
	public def iterator() = this.heap.iterator();

    public def heapify() {
        for (var i:Long = this.heap.size() / 2 - 1; i >= 0; i--) {
            this.siftdown(i, this.heap(i));
		}
    }

	public def siftup(k:Long, x:T) {
		var i:Long = k;
		while (i > 0) {
			var parent:Long = PARENT(i);
			var e:T = this.heap(parent);
			if (this.comparator(x, e) >= 0) {
				break;
			}
			this.heap(i) = e;
			i = parent;
		}
		this.heap(i) = x;
	}

	public def siftdown(k:Long, x:T) {
		var i:Long = k;
		val half = this.heap.size() / 2;
		while (i < half) {
			var child:Long = LEFT(i);
			var e:T = this.heap(child);
			val right = RIGHT(i);
			if (right < this.heap.size() && this.comparator(e, this.heap(right)) > 0) {
				child = right;
				e = this.heap(child);
			}
			if (this.comparator(x, e) <= 0) {
				break;
			}
			this.heap(i) = e;
			i = child;
		}
		this.heap(i) = x;
	}

	public static def main(Rail[String]) {
		var last:Long;
		val random = new Random();

		// Test a min-heap.
		val h = new HeapQueue[Long]((x:Long, y:Long)=> Math.signum(x - y) as Int); // min-heap
		for (i in 0..10) {
			h.push(random.nextLong(10) - 5);
		}
		last = Long.MIN_VALUE;
		for (i in 0..10) {
			Console.OUT.println(h.heap);
			val x = h.pop();
			Console.OUT.println(x);
			assert last <= x;
			last = x;
		}

		// Test a max-heap.
		val g = new HeapQueue[Long]((x:Long, y:Long)=> Math.signum(y - x) as Int); // max-heap
		for (i in 0..10) {
			g.push(random.nextLong(10) - 5);
		}
		last = Long.MAX_VALUE;
		for (i in 0..10) {
			Console.OUT.println(g.heap);
			val x = g.pop();
			Console.OUT.println(x);
			assert last >= x;
			last = x;
		}

		// Test for the remove operation.
		val a = new HeapQueue[Long]((x:Long, y:Long)=> Math.signum(x - y) as Int);
		a.push(-5);
		a.push(0);
		a.push(0);
		a.push(+5);
		Console.OUT.println(a.heap);
		a.remove(0);
		Console.OUT.println(a.heap);
		a.remove(0);
		Console.OUT.println(a.heap);
		a.remove(+5);
		Console.OUT.println(a.heap);
		a.remove(-5);
		Console.OUT.println(a.heap);

		// Test for the heapify operation.
		val b = new HeapQueue[Long]((x:Long, y:Long)=> Math.signum(x - y) as Int);
		for (i in 0..10) {
			b.heap.add(random.nextLong(10) - 5); // Bad access!!
		}
		Console.OUT.println(b.heap);
		b.heapify();
		last = Long.MIN_VALUE;
		for (i in 0..10) {
			Console.OUT.println(b.heap);
			val x = b.pop();
			Console.OUT.println(x);
			assert last <= x;
			last = x;
		}
	}
}
