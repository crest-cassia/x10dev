package tekram.test;
import x10.util.Random;
import x10.util.ArrayList;
import tekram.util.HeapQueue;

public class HeapQueueTest {
	
	static class Mock {
		
		public var id:Long;
		
		public def this(id:Long) {
			this.id = id;
		}
		
		public def toString():String {
			return ""+ this.id;
		}
	}

	
	public static def main(Rail[String]) {
		val random = new Random();
		val size = 100;
		val a = new ArrayList[Mock](size);
		for (var i:Long = 0; i < size; i++) {
			a.add(new Mock(random.nextLong(size * 2)));
		}
		val q = new HeapQueue[Mock]((one:Mock, other:Mock) => (one.id - other.id) as Int);
		for (x in a) {
			q.add(x);
		}
		val it = q.iterator();
		while (it.hasNext()) {
			val x = it.next();
			it.remove();
			Console.OUT.println("#" + x);
		}
		for (var i:Long = 0; i < size; i++) {
			val qm = q.poll();
			Console.OUT.println(qm);
		}
	}
}