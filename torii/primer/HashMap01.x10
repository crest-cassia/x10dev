import x10.util.HashMap;
import x10.util.Box;

public class HashMap01 {
	
	public static def main(Rail[String]) {
		val h = new HashMap[String,Long]();
		h.put("A", 1);
		h.put("B", 2);
		
		Console.OUT.println(h.get("B"));
		
		//var a:Long = h.get("A");       // Wrong.
		var a:Box[Long] = h.get("A");    // Truth.  No Auto-boxing in X10.
		Console.OUT.println(a());        // Un-boxing.
		
		for (entry in h.entries()) {
			// An instance of Map.Entry<K,V>. 
			Console.OUT.println(entry.getKey() + ":" + entry.getValue());
		}
		
		var b:Box[Long] = h.remove("B");
		
		var c:Long = h.getOrElse("C", 9);    // Default.  Non-boxed.
	}
}
