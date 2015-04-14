import x10.util.ArrayList;
import x10.util.List;

public class List01 {
	
    public static def main(args: Rail[String]) {
    	val a = new ArrayList[Long]();
    	a.add(101);
    	a.add(102);
    	val l = a as List[Long];
    	
    	Console.OUT.println(a.get(0));
    	Console.OUT.println(a.get(1));
    	//Console.OUT.println(l.get(1)); // No List.get()
    	Console.OUT.println(l(0)); // Equiv to a.get(0);
    	Console.OUT.println(l(1)); // Equiv to a.get(1);
    }
}
