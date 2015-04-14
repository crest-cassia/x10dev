public class Class01 {
	
	static class Circle {
		public var x:double;
		public var y:double;
		public var r:double;
		
		public def this() {
			this(0, 0, 0);
		}
		
		public def this(x:double, y:double, r:double) {
			this.x = x;
			this.y = y;
			this.r = r;
		}
		
		public def getX() = x;
		
		public def getY() = y;
		
		public def getR() = r;
		
		public def getArea() = Math.PI * r * r;
		
		public def toString() = "[Circle]{x:" + x + ", y:" + y + ", r:" + r + "}";
	}
	
    public static def main(Rail[String]) {
    	val c = new Circle(1, 1, 2.5);
    	Console.OUT.println(c);
    	Console.OUT.println(c.getArea());
    }
}