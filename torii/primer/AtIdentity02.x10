
public class AtIdentity02 {

	static class X {}

	public static def main(Rail[String]) {

		val x = new X();

		val y = at (here) { return x; };

		Console.OUT.println(x == y); // false.
	}
}
