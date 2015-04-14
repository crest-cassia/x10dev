public class Hello {
	
    public static def main(Rail[String]) {
    	finish for (p in Place.places()) {
    		async at (p) {
    			Console.OUT.println("Hello from place " + p.id);
    		}
    	}
    }
}
