import x10.io.Console;
import x10.util.ArrayList;
import x10.util.HashMap;

public class Tables {
  public val runsTable: HashMap[Long,Run];
  public val psTable: HashMap[Long,ParameterSet];
  public val boxesTable: HashMap[Long,Box];
  var maxRunId: Long = 0;
  var maxPSId: Long = 0;
  var maxBoxId: Long = 0;

  def this() {
    runsTable = new HashMap[Long, Run]();
    psTable = new HashMap[Long, ParameterSet]();
    boxesTable = new HashMap[Long, Box]();
  }

  def printRunsTable() {
    for( entry in runsTable.entries() ) {
      Console.OUT.println(entry.getKey() + ":" + entry.getValue() );
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

  private def createParameterSets( box: Box ): ArrayList[Task] {
    val newTasks = new ArrayList[Task]();
    val newPSs = box.createParameterSets( this );
    for( ps in newPSs ) {
      val numRunsToAdd = 1 - ps.numRuns();
      val newRuns = ps.createRuns( this, numRunsToAdd );
      for( run in newRuns ) {
        newTasks.add( run.generateTask() );
      }
    }
    return newTasks;
  }

  def createBox( betaMin: Double, betaMax: Double, hMin: Double, hMax: Double ): ArrayList[Task] {
    val newTasks: ArrayList[Task];
    val box:Box;
    atomic {
      box = new Box( maxBoxId, betaMin, betaMax, hMin, hMax );
      maxBoxId += 1;
      // TODO: check whether the new box is finished or not
      boxesTable.put( box.id, box );
      newTasks = createParameterSets( box );
    }
    return newTasks;
  }

}

