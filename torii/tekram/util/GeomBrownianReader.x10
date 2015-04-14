package tekram.util;
import x10.io.File;
import x10.io.FileReader;

public class GeomBrownianReader extends GeomBrownian {
	
	var reader:FileReader;

	public def this(fileName:String) {
		super(null, 0.0, 1.0, 1.0, 1.0);
		this.reader = new FileReader(new File(fileName));
	}

	public def nextBrownian():Double {
		return Double.parse(this.reader.readLine());
	}

	public static def main(Rail[String]) {
		// File path from the directory where the root package is placed.
		// E.g. This is "tekram/util/GeomBrownianReader.x10".
		val g = new GeomBrownianReader("gbm.dat");
		for (j in 0..10000) {
			Console.OUT.println(g.nextBrownian());
		}
	}
}
