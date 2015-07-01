
public class Truncate {

	public static def main(Rail[String]) {
		
		val w = 0.5;
		for (var d:Double = -5.0; d < 5.1; d += 0.1) {
			val x = Math.floor(d / w) * w;
			Console.OUT.println(d + "  " + x);
		}
	}
}
