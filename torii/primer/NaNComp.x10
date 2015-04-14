
public class NaNComp {

	public static def main(Rail[String]) {
		val d = Double.NaN;
		Console.OUT.println(d < 0.0);
		Console.OUT.println(d == 0.0);
		Console.OUT.println(d > 0.0);
	}
}
