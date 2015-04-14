public class Class02 {
	
	static interface Spatial {
		public def getVolume():Double;    // No need of the abstract keyword.
		public def getDimension():Long;
	}
	
	static abstract class Shape implements Spatial {
		
		public var x:Double;
		public var y:Double;
		
		public def this(x:Double, y:Double) {
			this.x = x;
			this.y = y;
		}
		
		public def getX():Double = x;
		
		public def getY():Double = y;
		
		public def getDimension() = 2;    // The return type can be omitted; X10 infers it.
	}
	
	static class Point extends Shape {
		
		public def this(x:Double, y:Double) {
			super(x, y);
		}
		
		public def this() {
			super(0, 0);
		}
		
		public def getVolume() = 0.0;
	}
	
	static class Rect extends Shape {
		
		public var width:Double;
		public var height:Double;
		
		public def this(x:Double, y:Double, width:Double, height:Double) {
			super(x, y);
			this.width = width;
			this.height = height;
		}
		
		public def getVolume() = width * height;
		
		public def getWidth() = width;
		
		public def setWidth(width:Double) {
			this.width = width;
		}
		
		public def getHeight() = height;
		
		public def setHeight(height:Double) {
			this.height = height;
		}
	}
	
	static class Circle extends Shape {
		
		public var radius:Double;
		
		public def this(x:Double, y:Double, radius:Double) {
			super(x, y);
			this.radius = radius;
		}
		
		public def getVolume() = Math.PI * radius * radius;
		
		public def getRadius() = radius;
		
		public def setRadius(radius:Double) {
			this.radius = radius;
		}
	}
	
	static class Square extends Rect {
		
		public def this(x:Double, y:Double, length:Double) {
			super(x, y, length, length);
		}
		
		public def getLength() = width;
		
		public def setLength(length:Double) {
			setWidth(length);
			setHeight(length);
		}
		public def setWidth(width:Double) {
			throw new IllegalOperationException("Use Square#setLength()");
		}
		
		public def setHeight(height:Double) {
			throw new IllegalOperationException("Use Square#setLength()");
		}
	}
	
    public static def main(Rail[String]) {
    	val rect = new Rect(0, 0, 100, 100);
    	val circle = new Circle(0, 0, 50);
    	val point = new Point(0, 0);
    	val square = new Square(0, 0, 100);
    	var shape:Shape;
    	
    	shape = point;
    	Console.OUT.println("shape = point; shape.getVolume() " + shape.getVolume());
    	
    	shape = rect;
    	Console.OUT.println("shape = rect; shape.getVolume() " + shape.getVolume());
    	
    	shape = circle;
    	Console.OUT.println("shape = circle; shape.getVolume() " + shape.getVolume());

    	square.setWidth(50); // BAD operation! It is not a SQUARE anymore!
    }
}
