import x10.io.Console;
import x10.io.File;
import x10.util.HashMap;
import x10.util.Box;

class TaskListParser {

  public static def parseFile( taskFile: String ): HashMap[String,String] {
    val parsed = new HashMap[String,String]();

    val input = new File(taskFile);
    for( line in input.lines() ) {
      Console.OUT.println(line);
      val a:Rail[String] = line.split(":");
      if( a.size == 2 ) {
        parsed.put( a(0), a(1) );
      }
    }
    return parsed;
  }

  static public def main(args:Rail[String]): void {
    val h: HashMap[String,String] = parseFile(args(0));

    for( entry in h.entries() ) {
      Console.OUT.println(entry.getKey() + ":" + entry.getValue());
    }
  }
}

