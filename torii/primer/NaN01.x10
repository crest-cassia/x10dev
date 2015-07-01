
public class NaN01 {

	public static def main(Rail[String]) {
		Console.OUT.println(Double.NaN - 2);
		Console.OUT.println(Double.NaN + 2);
		Console.OUT.println(Double.NaN * 2);
		Console.OUT.println(Double.NaN / 2);

		Console.OUT.println(Double.NaN as Long - 2);
		Console.OUT.println(Double.NaN as Long + 2);
		Console.OUT.println(Double.NaN as Long * 2);
		Console.OUT.println(Double.NaN as Long / 2);
	}
}
