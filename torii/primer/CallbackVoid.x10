
public class CallbackVoid {


	public static def f(g:(Long)=>void) {
		g(0);
	}

	public static def h(i:Long) {}

	public static def main(Rail[String]) {
		f((i:Long) => h(i));
	}
}
