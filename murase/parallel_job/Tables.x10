import x10.io.Console;
import x10.util.ArrayList;
import x10.util.HashMap;
import x10.util.Random;

public class Tables {
  public val runsTable: HashMap[Long,Run];
  public val psTable: HashMap[Long,ParameterSet];
  var maxRunId: Long = 0;
  var maxPSId: Long = 0;
  val random: Random;
  static val seedMax: Int = 1073741824n;

  def this( randSeed: Long ) {
    runsTable = new HashMap[Long, Run]();
    psTable = new HashMap[Long, ParameterSet]();
    random = new Random( randSeed );
  }

  def nextSeed(): Int {
    return random.nextInt( seedMax );
  }

  def printRunsTable() {
    atomic {
      for( entry in runsTable.entries() ) {
        Console.OUT.println(entry.getKey() + ":" + entry.getValue() );
      }
    }
  }

  def runsJson(): String {
    var json:String = "[\n";
    for( entry in runsTable.entries() ) {
      val run = entry.getValue();
      json += run.toJson() + ",\n";
    }
    val s = json.substring( 0n, json.length()-2n ) + "\n]";
    return s;
  }

  def parameterSetsJson(): String {
    var json: String = "[\n";
    for( entry in psTable.entries() ) {
      val ps = entry.getValue();
      json += ps.toJson() + ",\n";
    }
    val s = json.substring( 0n, json.length()-2n ) + "\n]";
    return s;
  }
}

