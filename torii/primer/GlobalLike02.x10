
public class GlobalLike02 {

	var GLOBAL_VARIABLE:Double;

	public def this() {
	}

	public def _main_() {
		GLOBAL_VARIABLE = 1;
		Console.OUT.println(GLOBAL_VARIABLE);
	}

	public static def main(args:Rail[String]) {
		new GlobalLike02()._main_();
	}
}

