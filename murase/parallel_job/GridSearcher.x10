import x10.util.ArrayList;

public class GridSearcher {

  def this() {
  }

  def generateTasks( table: Tables, finishedRun: Run ): ArrayList[Task] {
    val newTasks: ArrayList[Task] = new ArrayList[Task]();
    val appendTask = ( toAdd: ArrayList[Task] ) => {
      for( task in toAdd ) {
        newTasks.add( task );
      }
    };

    val ps = finishedRun.parameterSet( table );
    val boxes = ps.boxes( table );
    for( box in boxes ) {
      if( needsToDivide( table, box ) ) {
        Console.OUT.println("  dividing box " + box.id );
        val tasks = divideBox( table, box );
        appendTask( tasks );
      }
    }
    return newTasks;
  }

  private def needsToDivide( table: Tables, box: Box ): Boolean {
    if( box.divided == true || box.isFinished( table ) == false ) { return false; }
  
    val results = new ArrayList[Double]();
    for( ps in box.parameterSets( table ) ) {
      val result = ps.averagedResult( table );
      results.add( result );
    }
    results.sort();
    val resultDiff = results.getLast() - results.getFirst();
    Console.OUT.println( "  resultDiff of Box(" + box.id + ") : " + resultDiff );
    return ( box.betaMax - box.betaMin > 0.05 &&
             box.hMax - box.hMin > 0.1 &&
             resultDiff > 1.0 );
  } 

  def divideBox( table: Tables, box: Box ): ArrayList[Task] {
    Console.OUT.println("  dividing : " + box.id );
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
    val t1 = table.createBox( betaMin, betaHalf, hMin, hHalf );
    val t2 = table.createBox( betaMin, betaHalf, hHalf, hMax );
    val t3 = table.createBox( betaHalf, betaMax, hMin, hHalf );
    val t4 = table.createBox( betaHalf, betaMax, hHalf, hMax );
    addNewTasks( t1 );
    addNewTasks( t2 );
    addNewTasks( t3 );
    addNewTasks( t4 );
    box.divided = true;

    Console.OUT.println( "newTasks : " + newTasks );

    return newTasks;
  }
}

