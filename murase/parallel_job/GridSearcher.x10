import x10.util.ArrayList;

public class GridSearcher {

  val boxes: ArrayList[Box];
  val targetNumRuns = 1;

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
      if( box.divided == false && box.isFinished( table ) == true ) {
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

  private def averageResults( table: Tables, parameterSets: ArrayList[ParameterSet] ): Double {
    var sum: Double = 0.0;
    for( ps in parameterSets ) {
      val r = ps.averagedResult( table );
      sum += r;
    }
    return sum / parameterSets.size();
  }

  private def needsToDivideInBeta( table: Tables, box: Box ): Boolean {
    // check beta direction
    val results = new ArrayList[Double]();
    val psBetaMax = box.parameterSetsWhere( table, (ps: ParameterSet): Boolean => {
        return ps.params.beta == box.betaMax;
      } );
    val psBetaMin = box.parameterSetsWhere( table, (ps: ParameterSet): Boolean => {
        return ps.params.beta == box.betaMin;
      } );
    val resultBetaMax = averageResults( table, psBetaMax );
    val resultBetaMin = averageResults( table, psBetaMin );
    val resultDiff = Math.abs( resultBetaMax - resultBetaMin );
    Console.OUT.println( "  resultDiff of Box(" + box + ") in beta direction : " + resultDiff );
    return ( box.betaMax - box.betaMin > 0.005 &&
             resultDiff > 0.5 );
  }

  private def needsToDivideInH( table: Tables, box: Box ): Boolean {
    // check beta direction
    val results = new ArrayList[Double]();
    val psHMax = box.parameterSetsWhere( table, (ps: ParameterSet): Boolean => {
        return ps.params.h == box.hMax;
      } );
    val psHMin = box.parameterSetsWhere( table, (ps: ParameterSet): Boolean => {
        return ps.params.h == box.hMin;
      } );
    val resultHMax = averageResults( table, psHMax );
    val resultHMin = averageResults( table, psHMin );
    val resultDiff = Math.abs( resultHMax - resultHMin );
    Console.OUT.println( "  resultDiff of Box(" + box + ") in h direction : " + resultDiff );
    return ( box.hMax - box.hMin > 0.01 &&
             resultDiff > 0.5 );
  } 

  private def divideBox( table: Tables, box: Box ): ArrayList[Task] {
    Console.OUT.println("  dividing : " + box );

    val betaMin = box.betaMin;
    val betaMax = box.betaMax;
    val betaHalf = (betaMin + betaMax) / 2.0;
    val hMin = box.hMin;
    val hMax = box.hMax;
    val hHalf = (hMin + hMax) / 2.0;
    // val lMin = box.lMin;
    // val lMax = box.lMax;
    // var lHalf: Long = ( lMin + lMax ) / 2;
    // if( lHalf % 2 == 1 ) { lHalf += 1; }  // lHalf must be even

    val divBeta = needsToDivideInBeta( table, box );
    val divH    = needsToDivideInH( table, box );

    val newBoxes = new ArrayList[Box]();
    if( divBeta && divH ) {
      newBoxes.add( Box.create( betaMin, betaHalf, hMin, hHalf ) );
      newBoxes.add( Box.create( betaMin, betaHalf, hHalf, hMax ) );
      newBoxes.add( Box.create( betaHalf, betaMax, hMin, hHalf ) );
      newBoxes.add( Box.create( betaHalf, betaMax, hHalf, hMax ) );
    }
    else if( divBeta ) {
      newBoxes.add( Box.create( betaMin, betaHalf, hMin, hMax ) );
      newBoxes.add( Box.create( betaHalf, betaMax, hMin, hMax ) );
    }
    else if( divH ) {
      newBoxes.add( Box.create( betaMin, betaMax, hMin, hHalf ) );
      newBoxes.add( Box.create( betaMin, betaMax, hHalf, hMax ) );
    }

    val newTasks = new ArrayList[Task]();
    for( newBox in newBoxes ) {
      val tasks = newBox.createSubTasks( table, targetNumRuns );
      for( task in tasks ) {
        newTasks.add( task );
      }
      boxes.add( newBox );
    }

    box.divided = true;

    Console.OUT.println( "newTasks : " + newTasks );

    return newTasks;
  }
}

