import x10.util.List;
import x10.util.ArrayList;

public class List02 {

	public static def main(Rail[String]) {
		val a = new ArrayList[Long]() as List[Long];
		a.add(0);
		Console.OUT.println(a);

		a(0) += 10;
		Console.OUT.println(a);
	
		//a.getLast() += 10; // This is not allowed.
		//Console.OUT.println(a);
	}
}
