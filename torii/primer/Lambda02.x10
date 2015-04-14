
public class Lambda02 {
	
	public static def main(Rail[String]) {
		val sq = (x:long) => x * x;
		val times = (x:long) => {
				var s:String = "";
				for (val i in 1 .. x) {
					s += i + " ";
				}
				return s;
			};
		for (val i in 1 .. 4) {
			Console.OUT.println(sq(i));
			Console.OUT.println(times(i));
		}
	}
}
