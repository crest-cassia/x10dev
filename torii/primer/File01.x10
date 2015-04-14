import x10.io.File;

public class File01 {

	public static def main(args:Rail[String]) {
		val f = new File("aaa");
		for (line in f.lines()) {
			Console.OUT.print(line);
		}
	}
}
