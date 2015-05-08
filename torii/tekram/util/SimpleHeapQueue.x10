package tekram.util;
import x10.util.ArrayList;
import x10.util.List;
import x10.util.Random;

public class SimpleHeapQueue[T] {

	public var heap:List[T];
	public var comparator:(T,T)=>Long;
	
	public def this(comparator:(T,T)=>Long) {
		this.heap = new ArrayList[T]();
		this.comparator = comparator;
	}

	static def PARENT(i:Long) = i / 2;
	static def LEFT(i:Long)  = 2 * i + 1;
	static def RIGHT(i:Long) = 2 * i + 2;

	public def swap(i:Long, j:Long) {
		val x = this.heap(i);
		this.heap(i) = this.heap(j);
		this.heap(j) = x;
	}

	public def heapify(i:Long) {
		var pivot:Long = i;
		if (LEFT(i) < this.heap.size() && this.comparator(this.heap(LEFT(i)), this.heap(i)) < 0) {
			pivot = LEFT(i);
		}
		if (RIGHT(i) < this.heap.size() && this.comparator(this.heap(RIGHT(i)), this.heap(pivot)) < 0) {
			pivot = RIGHT(i);
		}
		if (pivot != i) {
			this.swap(i, pivot);
			this.heapify(pivot);
		}
	}

	public def push(x:T) {
		var i:Long = this.heap.size();
		while (i > 0 && this.comparator(x, this.heap(PARENT(i))) < 0) {
			this.heap(i) = this.heap(PARENT(i));
			i = PARENT(i);
		}
		this.heap(i) = x;
	}

	public def pop():T {
		val x = this.heap(0);
		this.heap(0) = this.heap.removeLast();
		this.heapify(0);
		return x;
	}

	public static def main(Rail[String]) {
		val random = new Random();
		val h = new SimpleHeapQueue[Long]((x:Long, y:Long)=> x - y); // min-heap
		for (i in 0..10) {
			h.push(random.nextLong(10) - 5);
		}
		for (i in 0..10) {
			Console.OUT.println(h.heap);
			val x = h.pop();
			Console.OUT.println(x);
		}
		val g = new SimpleHeapQueue[Long]((x:Long, y:Long)=> y - x); // max-heap
		for (i in 0..10) {
			g.push(random.nextLong(10) - 5);
		}
		for (i in 0..10) {
			Console.OUT.println(g.heap);
			val x = g.pop();
			Console.OUT.println(x);
		}
	}
}
