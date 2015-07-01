import x10.util.HashMap;
import x10.util.Box;

// X10 2.5
public class HashMap02 {
	
	public static def main(Rail[String]) {
		val h = new HashMap[String,Long]();
		h.put("A", 1);
		h.put("B", 2);
		h("D") = 3;    // New feature since 2.5.
		Console.OUT.println(h("D"));
		
		Console.OUT.println(h.get("B"));
		
		var a:Long = h.get("A");    // Auto-boxing in X10 2.5.
		Console.OUT.println(a);
		
		for (entry in h.entries()) {
			// An instance of Map.Entry<K,V>. 
			Console.OUT.println(entry.getKey() + ":" + entry.getValue());
		}
		
		var b:Long = h.remove("B");
		
		var c:Long = h.getOrElse("C", 9);    // Default.  Non-boxed.
	}
}
