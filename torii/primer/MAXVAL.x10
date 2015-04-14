
public class MAXVAL {

	public static def main(Rail[String]) {
		Console.OUT.println(Long.MIN_VALUE);
		//-9223372036854775808
		Console.OUT.println(Double.MIN_VALUE);
		//4.9E-324

		Console.OUT.println(Long.MAX_VALUE + 1);
		//-9223372036854775808
		Console.OUT.println(Long.MAX_VALUE - 1);
		//9223372036854775806
		Console.OUT.println(Double.MAX_VALUE + 1);
		//1.7976931348623157E308
		Console.OUT.println(Double.MAX_VALUE - 1);
		//1.7976931348623157E308

		Console.OUT.println(Long.MIN_VALUE + 1);
		//-9223372036854775807
		Console.OUT.println(Long.MIN_VALUE - 1);
		//9223372036854775807
		Console.OUT.println(Double.MIN_VALUE + 1.0);
		//1.0
		Console.OUT.println(Double.MIN_VALUE - 1.0);
		//-1.0

	}
}
