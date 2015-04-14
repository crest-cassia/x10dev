package tekram.util;

public class Counter {
	
	public var value:Long;
	
	public def this() {
		this(0);
	}
	
	public def this(value:Long) {
		this.value = value;
	}
	
	public def set(value:Long) {
		this.value = value;
	}
	
	public def get():Long {
		return this.value;
	}
	
	public def next():Long {
		return ++this.value;
	}
}
