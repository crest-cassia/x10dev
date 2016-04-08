import x10.util.ArrayList;
import x10.util.Random;

//FROM JAVA
//Returns:
//index of the search key, if it is contained in the array; otherwise, (-(insertion point) - 1). The insertion point is defined as the point at which the key would be inserted into the array: the index of the first element greater than the key, or a.length if all elements in the array are less than the specified key. Note that this guarantees that the return value will be >= 0 if and only if the key is found.

class BinSearch {

	public static def main(Rail[String]) {
		val r = new Random();
		val a = new ArrayList[Long]();

		for (t in 1..10) {
			a.add(r.nextLong(10));
		}

		a.sort();
		val key = 5;
		val i = a.binarySearch(key);
		Console.OUT.println(a);
		Console.OUT.println(key);
		Console.OUT.println(i);
	}
}
