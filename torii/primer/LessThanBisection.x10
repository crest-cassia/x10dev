import x10.util.ArrayList;
import x10.util.Random;
import x10.util.Pair;

public class LessThanBisection {

	static type P = Pair[Long,Long];

	public static def main(Rail[String]) {
		val random = new Random();
		val a = new ArrayList[P]();

		val SORTER = (one:P, other:P) => {
			if (one.first < other.first) {
				return -1n;
			}
			if (one.first > other.first) {
				return +1n;
			}
			if (one.second <= other.second) {
				return  0n;
			}
			if (one.second > other.second) {
				return +1n;
			}
			return 0n;
		};

		for (t in 1..20) {
			val x = random.nextLong(5);
			val y = random.nextLong(5);
			val p = new P(x, y);
			val i = a.binarySearch(p, SORTER);
			if (i < 0) {
				a.addBefore(-i - 1, p);
			}
			Console.OUT.println(a);
		}
	}
}
