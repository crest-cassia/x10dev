public class String01 {
	
    public static def main(Rail[String]) {
    	Console.OUT.println(String.format("%d", [1 as Any]));
    	Console.OUT.println(String.format("%d %f %s %s", [1, 2.3, "four", new String01()]));
    }
}