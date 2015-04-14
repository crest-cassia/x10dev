import x10.util.ArrayList;
import x10.regionarray.*;

public class ArrayList01 {

    public static def main(Rail[String]) {
    	val a = new ArrayList[String](10);
    	a.add("a");
    	a.add("b");
    	a.add("c");
    	Console.OUT.println(a.size());
    	
    	for (v in a) {
    		Console.OUT.println(v);
    	}
    }
}