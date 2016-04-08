import x10.util.Random;

public class Round01 {

	public static def main(Rail[String]) {
		val r = new Random();
		val d = r.nextDouble() * 300;
		val n = r.nextLong(5);
		val p = Math.pow(10, -n);

		val df = Math.floor(d / p) * p;
		val dc = Math.ceil(d / p) * p;
		val ds = String.format("%." + n + "f", [df as Any]);

		Console.OUT.println("original: " + d + " with " + p);
		Console.OUT.println("floor: " + df);
		Console.OUT.println("ceil: " + dc);
		Console.OUT.println("string: " + ds + ", " + Double.parse(ds));
	}
}
