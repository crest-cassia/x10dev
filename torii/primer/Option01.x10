import x10.util.OptionsParser;
import x10.util.Option;
import x10.util.ArrayList;
import x10.util.HashMap;

public class Option01 {
	
	public static def main(Rail[String]) {
		val MULTIPLE = true;
		val REQUIRED = true;
		
		val args = ["-a", "1", "--outfile", "f.dat", "-q"];
		
		val options = new ArrayList[Option]();
		options.add(new Option("-a", "", "parameter a", 1n, !MULTIPLE, REQUIRED));
		options.add(new Option("-o", "--outfile", "output file", 1n, !MULTIPLE, REQUIRED));
		options.add(new Option("-i", "--infile", "input file", 1n));
		
		val opt = new OptionsParser(args, options.toRail());
		
		Console.OUT.println(opt.get("outfile"));
		Console.OUT.println(opt("outfile"));              // Test if the key exists.
		Console.OUT.println(opt("outfile", "stdout"));    // If single arg.
		Console.OUT.println(opt("infile", "stdin"));      // If single arg.
		
		Console.OUT.println(opt.usage(""));
	}
}