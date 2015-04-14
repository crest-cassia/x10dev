
public class ZeroDiv {

	public static def main(Rail[String]) {
		Console.OUT.println(1.0 / 0.0); // Inf
		Console.OUT.println(1 / 0);     // Arithmetic Exception
	}
}
