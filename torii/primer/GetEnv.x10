
public class GetEnv {

	public static def main(args:Rail[String]) {
		val s = System.getenv("X10_NTHREADS");
		Console.OUT.println(s);
	}
}
