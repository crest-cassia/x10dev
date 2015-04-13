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
    if( box.isFinished( this ) == false ) { return false; }
  
    val results = new ArrayList[Double]();
    for( psId in box.psIds ) {
      val ps = psTable.get( psId );
      val result = averagedResult( ps );
      results.add( result );
    }
    results.sort();
    val resultDiff = results.getLast() - results.getFirst();
    Console.OUT.println( "  resultDiff : " + resultDiff );
    return ( box.betaMax - box.betaMin > 0.005 &&
             box.hMax - box.hMin > 0.005 &&
             resultDiff > 0.1 );
    // return ( resultDiff > 0.2 );
  }

  private def averagedResult( ps: ParameterSet ): Double {
    var sum: Double = 0.0;
    for( runId in ps.runIds ) {
      val run = runsTable.get( runId );
      sum += run.result;
    }
    return sum / ps.runIds.size();
  }

  private def createRuns( ps: ParameterSet, numRuns: Long ): ArrayList[Task] {
    // TODO: implement numRuns
    val newTasks = new ArrayList[Task]();
    val run = new Run( maxRunId, ps );
    maxRunId += 1;
    runsTable.put( run.id, run );
    ps.runIds.add( run.id );
    newTasks.add( run.generateTask() );
    return newTasks;
  }

  private def createParameterSets( box: Box ): ArrayList[Task] {
    val newTasks = new ArrayList[Task]();
    val addPS = (beta:Double, h:Double) => {
      val idx = findPS( beta, h );
      val ps: ParameterSet;
      if( idx >= 0 ) {
        ps = psTable.get(idx);
      }
      else {
        ps = new ParameterSet( maxPSId, beta, h );
        maxPSId += 1;
        psTable.put( ps.id, ps );
        val a = createRuns( ps, 1 );
        for( task in a ) { newTasks.add( task ); }
      }
      Console.OUT.println("PS: " + ps);
      Console.OUT.println("run: " + ps.runIds);
      if( ps.isFinished( this ) == false ) {
        Console.OUT.println("  pushing box to PS : " + box.id );
        ps.pushParentBoxId( box.id );
      }
      box.appendParameterSet( ps );
    };
    atomic {
      addPS( box.betaMin, box.hMin );
      addPS( box.betaMin, box.hMax );
      addPS( box.betaMax, box.hMin );
      addPS( box.betaMax, box.hMax );
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

    Console.OUT.println( "newTasks : " + newTasks );

    return newTasks;
  }
}

