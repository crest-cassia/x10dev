
public class String02 {

	public static def main(Rail[String]) {
		
		val h = 37;
		val m = 21;
		val s = 12;

		val time = String.format("%02d:%02d:%02d", [h, m, s as Any]);
		Console.OUT.println(time);
	}
}
