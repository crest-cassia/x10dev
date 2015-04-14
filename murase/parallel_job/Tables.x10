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

  def boxNeedsToBeDivided( boxId: Long ): Boolean {
    val box = boxesTable.get( boxId );
    if( box.divided == true || box.isFinished( this ) == false ) { return false; }
  
    val results = new ArrayList[Double]();
    for( psId in box.psIds ) {
      val ps = psTable.get( psId );
      val result = ps.averagedResult( this );
      results.add( result );
    }
    results.sort();
    val resultDiff = results.getLast() - results.getFirst();
    Console.OUT.println( "  resultDiff of Box(" + boxId + ") : " + resultDiff );
    // return false;
    return ( box.betaMax - box.betaMin > 0.05 &&
             box.hMax - box.hMin > 0.1 &&
             resultDiff > 1.0 );
    // return ( resultDiff > 0.2 );
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

  def findPS( beta: Double, h:Double ): Long {
    for( entry in psTable.entries() ) {
      val ps = entry.getValue();
      if( ps.beta == beta && ps.h == h ) {
        return entry.getKey();
      }
    }
    return -1;
  }

  def getBoxIds( psId: Long ): ArrayList[Long] {
    return psTable.get(psId).getParentBoxIds();
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

  def divideBox( boxId: Long ): ArrayList[Task] {
    Console.OUT.println("  dividing : " + boxId );
    val box = boxesTable.get( boxId );
    val betaMin = box.betaMin;
    val betaMax = box.betaMax;
    val betaHalf = (betaMin + betaMax) / 2.0;
    val hMin = box.hMin;
    val hMax = box.hMax;
    val hHalf = (hMin + hMax) / 2.0;
    val newTasks = new ArrayList[Task]();
    val addNewTasks = ( tasks: ArrayList[Task] ): void => {
      for( task in tasks ) {
        newTasks.add( task );
      }
    };
    val t1 = createBox( betaMin, betaHalf, hMin, hHalf );
    val t2 = createBox( betaMin, betaHalf, hHalf, hMax );
    val t3 = createBox( betaHalf, betaMax, hMin, hHalf );
    val t4 = createBox( betaHalf, betaMax, hHalf, hMax );
    addNewTasks( t1 );
    addNewTasks( t2 );
    addNewTasks( t3 );
    addNewTasks( t4 );
    box.divided = true;

    Console.OUT.println( "newTasks : " + newTasks );

    return newTasks;
  }
}

