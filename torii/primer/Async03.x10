
class Async02b {
	
	public static def main(Rail[String]) {
		var x:long = 0;
		finish {
			async {
				atomic x = 100;
			}
			async {
				atomic x = 101;
			}
		}
		Console.OUT.println(x);
	}
}
