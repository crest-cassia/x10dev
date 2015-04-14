package tekram.test;
import x10.util.List;
import x10.util.ArrayList;

public class ListIter01 {

	public static def main(Rail[String]) {
		val a = new ArrayList[Double]() as List[Double];
		a.add(1);
		a.add(2);
		a.add(3);
		Console.OUT.println(a);
	}
}
