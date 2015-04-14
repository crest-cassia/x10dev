import x10.util.RailUtils;
import x10.util.Random;

public class Rail02 {
	
	public static def main(Rail[String]) {
		
		val rand = new Random();
		
		var a:Rail[long] = new Rail[long](10, (i:long) => i + 1);
		Console.OUT.println(a);
		
		RailUtils.map(a, a, (i:long) => i * i);    // Overwrite!
		Console.OUT.println(a);
		
		val sum = RailUtils.reduce(a, (x:long, y:long) => x + y, 0);
		val prod = RailUtils.reduce(a, (x:long, y:long) => x * y, 1);
		Console.OUT.println("sum: " + sum);
		Console.OUT.println("prod: " + prod);
		
		// shuffle(a)
		RailUtils.sort(a, (x:long, y:long) => Math.signum(rand.nextDouble() * 2 - 1) as int);
		Console.OUT.println(a);
		
		// sort(a)
		RailUtils.sort(a, (x:long, y:long) => Math.signum(x - y) as int);
		Console.OUT.println(a);
	}
}