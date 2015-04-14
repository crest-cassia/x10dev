public class Counter {
	
	var _value:Long;
	
	public def this() {
		_value = 0;
	}
	
	public operator this():Long {
		return _value++;
	}
	
    public static def main(Rail[String]) {
    	Console.OUT.println(Place.MAX_PLACES);
    	
    	val g = new GlobalRef[AtomicCounter](new AtomicCounter());
    	for (i in 1..10) {
    		async {
    			at (g.home) Console.OUT.println(g()());
    		}
    	}
    	
    	finish for (p in Place.places()) {
    		async at (p) {
    			at (g.home) Console.OUT.println(g()());
    		}
    	}
    	Console.OUT.println(g());
    }
}