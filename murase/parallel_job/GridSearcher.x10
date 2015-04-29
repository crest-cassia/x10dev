import x10.util.ArrayList;
import x10.regionarray.Region;

public class GridSearcher {

  val boxes: ArrayList[Box];
  val targetNumRuns = 1;
  val expectedResultDiff = 0.5;

  def this() {
    boxes = new ArrayList[Box]();
  }

  def debug( o: Any ): void {
    Console.ERR.println(o);
  }

  public def makeInitialBox( table: Tables, searchRegion: Region{self.rank==Simulator.numParams} ): ArrayList[Task] {
    val box = new Box( searchRegion );
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

  private def diffResults( table: Tables, parameterSets: ArrayList[ParameterSet] ): Double {
    assert parameterSets.size() == 2;
    val r0 = parameterSets(0).averagedResult( table );
    val r1 = parameterSets(1).averagedResult( table );
    debug( "  diffResults of " + parameterSets + " = " + Math.abs(r0-r1) );
    return Math.abs( r0 - r1 );
  }

  // return true if box needs to be divided in the direction of axis
  private def needToDivide( table: Tables, box: Box, axis: Long ): Boolean {
    if( box.region.projection( axis ).size() <= 1 ) { // undividable
      return false;
    }

    var maxDiff: Double = 0.0;

    val arraySmallerPS = box.parameterSetsWhere( table, (ps: ParameterSet) => {
      return ps.point( axis ) == box.region.min( axis );
    });
    for( smallerPS in arraySmallerPS ) {
      val psPairToCompare = box.parameterSetsWhere( table, (ps: ParameterSet) => {
        return ps.isSimilarToWithRespectTo( smallerPS, axis );
      });
      val diff = diffResults( table, psPairToCompare );
      if( diff > maxDiff ) {
        maxDiff = diff;
      }
    }

    Console.OUT.println( "  resultDiff of Box(" + box + ") in " + axis + " direction: " + maxDiff );

    return maxDiff > expectedResultDiff;
  }

  /*
  private def needsToDivideInBeta( table: Tables, box: Box ): Boolean {
    // check beta direction
    val results = new ArrayList[Double]();
    val psHMax = box.parameterSetsWhere( table, (ps: ParameterSet): Boolean => {
        return ps.params.h == box.hMax;
      } );
    val psHMin = box.parameterSetsWhere( table, (ps: ParameterSet): Boolean => {
        return ps.params.h == box.hMin;
      } );
    val diff1 = diffResults( table, psHMax );
    val diff2 = diffResults( table, psHMin );
    val resultDiff = Math.min( diff1, diff2 );
    Console.OUT.println( "  resultDiff of Box(" + box + ") in beta direction : " + resultDiff );
    return ( box.betaMax - box.betaMin > 0.005 &&
             resultDiff > expectedResultDiff );
  }

  private def needsToDivideInH( table: Tables, box: Box ): Boolean {
    // check beta direction
    val results = new ArrayList[Double]();
    val psBetaMax = box.parameterSetsWhere( table, (ps: ParameterSet): Boolean => {
        return ps.params.beta == box.betaMax;
      } );
    val psBetaMin = box.parameterSetsWhere( table, (ps: ParameterSet): Boolean => {
        return ps.params.beta == box.betaMin;
      } );
    val diff1 = diffResults( table, psBetaMax );
    val diff2 = diffResults( table, psBetaMin );
    val resultDiff = Math.min( diff1, diff2 );
    Console.OUT.println( "  resultDiff of Box(" + box + ") in h direction : " + resultDiff );
    return ( box.hMax - box.hMin > 0.01 &&
             resultDiff > expectedResultDiff );
  } 
  */

  private def divideBoxIn( box: Box, axis: Long ): ArrayList[Box] {
    val ranges = box.toRanges();
    val min = ranges( axis ).min;
    val max = ranges( axis ).max;
    val mid = (min + max) / 2;

    ranges(axis) = min..mid;
    val newRegion1 = Region.makeRectangular( ranges );
    val newBox1 = new Box( newRegion1 );

    ranges(axis) = mid..max;
    val newRegion2 = Region.makeRectangular( ranges );
    val newBox2 = new Box( newRegion2 );

    val boxes = new ArrayList[Box]();
    boxes.add( newBox1 );
    boxes.add( newBox2 );
    return boxes;
  }

  private def divideBox( table: Tables, box: Box ): ArrayList[Task] {
    Console.OUT.println("  dividing : " + box );

    var boxesToBeDivided: ArrayList[Box] = new ArrayList[Box]();
    boxesToBeDivided.add( box );

    val newBoxes = new ArrayList[Box]();
    for( axis in 0..(box.region.rank-1) ) {
      val bDivide = needToDivide( table, box, axis );
      if( bDivide ) {
        debug( "  dividing in " + axis + " direction : " + boxesToBeDivided );
        newBoxes.clear();
        for( boxToBeDivided in boxesToBeDivided ) {
          val dividedBoxes = divideBoxIn( boxToBeDivided, axis );
          boxToBeDivided.divided = true;
          newBoxes.addAll( dividedBoxes );
        }
        boxesToBeDivided = newBoxes.clone();
      }
    }
    debug( "  newBoxes: " + newBoxes );

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


  /*
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
  */
}

