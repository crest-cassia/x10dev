
class Async01 {
	
	public static def main(Rail[String]) {
		async at (here) {
			Console.OUT.println("Hello at " + here.id);
		}
		async at (here.next()) {
			Console.OUT.println("Hello at " + here.id);
		}
		async at (here) {
			Console.OUT.println("Hello at " + here.id);
		}
		async at (here.next()) {
			Console.OUT.println("Hello at " + here.id);
		}
	}
}
