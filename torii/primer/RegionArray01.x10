import x10.regionarray.*;

public class RegionArray01 {
	
	public static def main(Rail[String]) {
		val a = new Array[Long](10, (i:Long) => -i);
		
		// Use the destructive syntax, since the Array is defined over Points.
		// Otherwise, a(i) = i  arose an error, because i is an instance of Point. 
		for ([i] in a) {
			Console.OUT.println(i + ":" + a(i));
		}
		
		val b = a.map((i:Long) => i + 10);
		Console.OUT.println(b);
		
		Console.OUT.println(a.reduce((s:Long, x:Long) => s + x, 0));
	}
}