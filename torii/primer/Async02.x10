
class Async02 {
	
	static class Ref {
		public var x:long;
		
		public def this(x:long) {
			this.x = x;
		}
	}
	
	public static def main(Rail[String]) {
		val y = new Ref(0);
		val g = new GlobalRef[Ref](y);
		
		finish async at (g.home) {
			g().x = 1;
		}
		
		Console.OUT.println(y.x);
	}
}
