import x10.io.Console;
import x10.util.ArrayList;
import x10.util.HashMap;

public class Tables {
  public val runsTable: HashMap[Long,Run];
  public val boxesTable: HashMap[Long,Box];
  var maxRunId: Long = 0;
  var maxBoxId: Long = 0;

  def this() {
    runsTable = new HashMap[Long, Run]();
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

  private def isFinished( box: Box ): Boolean {
    var b: Boolean = true;
    for( runId in box.runIds ) {
      b = b && runsTable.get( runId ).finished;
    }
    return b;
  }

  def boxNeedsToBeDivided( boxId: Long ): Boolean {
    val box = boxesTable.get( boxId );
    if( isFinished( box ) == false ) { return false; }
  
    val results = new ArrayList[Double]();
    for( runId in box.runIds ) {
      val result = runsTable.get( runId ).result;
      results.add( result );
    }
    results.sort();
    val resultDiff = results.getLast() - results.getFirst();
    Console.OUT.println( "  resultDiff : " + resultDiff );
    return ( resultDiff > 0.2 );
  }

  private def createRuns( box: Box ): ArrayList[Task] {
    val newTasks = new ArrayList[Task]();
    val addRun = (beta:Double, h:Double) => {
      val idx = findRun( beta, h );
      val run: Run;
      if( idx >= 0 ) {
        run = runsTable.get(idx);
      }
      else {
        run = new Run( maxRunId, beta, h );
        maxRunId += 1;
        runsTable.put( run.id, run );
        newTasks.add( run.generateTask() );
      }
      if( run.finished == false ) {
        run.pushParentBoxId( box.id );
      }
      box.appendRun( run );
    };
    atomic {
      addRun( box.betaMin, box.hMin );
      addRun( box.betaMin, box.hMax );
      addRun( box.betaMax, box.hMin );
      addRun( box.betaMax, box.hMax );
    }
    return newTasks;
  }

  def findRun( beta: Double, h:Double ): Long {
    for( entry in runsTable.entries() ) {
      val r = entry.getValue();
      if( r.beta == beta && r.h == h ) {
        return entry.getKey();
      }
    }
    return -1;
  }

  def createBox( betaMin: Double, betaMax: Double, hMin: Double, hMax: Double ): ArrayList[Task] {
    val newTasks: ArrayList[Task];
    val box:Box;
    atomic {
      box = new Box( maxBoxId, betaMin, betaMax, hMin, hMax );
      maxBoxId += 1;
      // TODO: check whether the new box is finished or not
      boxesTable.put( box.id, box );
      newTasks = createRuns( box );
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

