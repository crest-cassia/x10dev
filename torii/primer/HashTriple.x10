import x10.util.Triple;
import x10.util.HashMap;
import x10.util.Random;

public class HashTriple {

	static type XYZ = Triple[Long,Long,Long];
	
	public static def main(Rail[String]) {
		val random = new Random();
		val h = new HashMap[XYZ,Long]();

		for (t in 1..10000) {
			val f1 = random.nextLong(5);
			val f2 = random.nextLong(5);
			val f3 = random.nextLong(5);
			val key = new XYZ(f1, f2, f3);
			if (!h.containsKey(key)) h(key) = 0;
			h(key) = h(key) + 1;
		}
		for (key in h.keySet()) {
			Console.OUT.println(key + " : " + h(key));
		}
	}
}
