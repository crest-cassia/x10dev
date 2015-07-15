
public class NonStaticVal {

	public val NON_STATIC_VAL:Long;

	public static def main(Rail[String]) {
		// Doesn't work.
		NonStaticVal.NON_STATIC_VAL = 0;
	}
}
