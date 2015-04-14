public class Rail01 {
	
	public static def main(Rail[String]) {
		val a = new Rail[Long](10);
		
		for (i in 0 .. (a.size - 1)) {
			a(i) = i;
		}
		Console.OUT.println(a);
		
		for (i in a) {
			a(i) = -i;
		}
		Console.OUT.println(a);
		
		val b = new Rail[Long](10, (i:Long) => i);
		Console.OUT.println(b);
		
		val zeros = new Rail[Double](10, 0.0);
		Console.OUT.println(zeros);
		
		val ones = new Rail[Double](10, 1.0);
		Console.OUT.println(ones);
	}
}