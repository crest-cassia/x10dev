import x10.util.ArrayList;

public class GridSearcher {

  val boxes: ArrayList[Box];
  val targetNumRuns = 5;

  def this() {
    boxes = new ArrayList[Box]();
  }

  public def makeInitialBox( table: Tables, betaMin: Double, betaMax: Double, hMin: Double, hMax: Double ): ArrayList[Task] {
    val box = Box.create( betaMin, betaMax, hMin, hMax );
    boxes.add( box );
    return box.createSubTasks( table, targetNumRuns );
  }

  public def onParameterSetFinished( table: Tables, finishedPS: ParameterSet ): ArrayList[Task] {
    val newTasks: ArrayList[Task] = new ArrayList[Task]();
    val appendTask = ( toAdd: ArrayList[Task] ) => {
      for( task in toAdd ) {
        newTasks.add( task );
      }
    };
    val boxes = findBoxesFromPS( finishedPS );
    for( box in boxes ) {
      if( needsToDivide( table, box ) ) {
        Console.OUT.println("  dividing box " + box );
        val tasks = divideBox( table, box );
        appendTask( tasks );
      }
    }
    return newTasks;
  }

  private def findBoxesFromPS( ps: ParameterSet ): ArrayList[Box] {
    val ret = new ArrayList[Box]();
    for( box in boxes ) {
      if( box.psIds.contains( ps.id ) ) {
        ret.add( box );
      }
    }
    return ret;
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
    Console.OUT.println( "  resultDiff of Box(" + box + ") : " + resultDiff );
    return ( box.betaMax - box.betaMin > 0.05 &&
             box.hMax - box.hMin > 0.1 &&
             resultDiff > 1.0 );
  } 

  private def divideBox( table: Tables, box: Box ): ArrayList[Task] {
    Console.OUT.println("  dividing : " + box );
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

    val b1 = Box.create( betaMin, betaHalf, hMin, hHalf );
    val b2 = Box.create( betaMin, betaHalf, hHalf, hMax );
    val b3 = Box.create( betaHalf, betaMax, hMin, hHalf );
    val b4 = Box.create( betaHalf, betaMax, hHalf, hMax );
    addNewTasks( b1.createSubTasks( table, targetNumRuns ) );
    addNewTasks( b2.createSubTasks( table, targetNumRuns ) );
    addNewTasks( b3.createSubTasks( table, targetNumRuns ) );
    addNewTasks( b4.createSubTasks( table, targetNumRuns ) );
    box.divided = true;

    Console.OUT.println( "newTasks : " + newTasks );

    return newTasks;
  }
}

