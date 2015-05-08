
public class GetEnv {

	public static def main(args:Rail[String]) {
		val env = System.getenv();
		for (key in env.keySet()) {
			Console.OUT.println(key + " : " + env.get(key));
		}
	}
}
