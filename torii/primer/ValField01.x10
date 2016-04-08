public class ValField01 {

	static class X {

		public val id:Long;

		public def this() {
		}
	}

	public static def main(Rail[String]) {
		val x = new X();
		x.id = 10;
	}
}
