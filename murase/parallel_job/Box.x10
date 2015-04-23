import x10.io.Console;
import x10.util.HashMap;
import x10.util.ArrayList;

public class Box {
  public val psIds: ArrayList[Long] = new ArrayList[Long]();
  public val betaMin: Double;
  public val betaMax: Double;
  public val hMin: Double;
  public val hMax: Double;
  public var divided: Boolean;

  def this(_betaMin:Double, _betaMax:Double, _hMin:Double, _hMax:Double) {
    betaMin = _betaMin;
    betaMax = _betaMax;
    hMin = _hMin;
    hMax = _hMax;
    divided = false;
  }

  def toString(): String {
    val str = "{ " +
               " betaMin: " + betaMin + "," +
               " betaMax: " + betaMax + "," +
               " hMin: " + hMin + "," +
               " hMax: " + hMax + "," +
               " psIds: " + psIds +
               " }";
    return str;
  }

  def isFinished( table: Tables ): Boolean {
    for( ps in parameterSets( table ) ) {
      if( ps.isFinished( table ) == false ) {
        return false;
      }
    }
    return true;
  }

  def parameterSets( table: Tables ): ArrayList[ParameterSet] {
    val a = new ArrayList[ParameterSet]();
    for( psId in psIds ) {
      val ps = table.psTable( psId );
      a.add( ps );
    }
    return a;
  }

  def createParameterSets( table: Tables ): ArrayList[ParameterSet] {
    val newPS = new ArrayList[ParameterSet]();

    val addPS = (beta:Double, h:Double) => {
      val ps = ParameterSet.findOrCreateParameterSet( table, beta, h );
      psIds.add( ps.id );
      newPS.add( ps );
    };

    addPS( betaMin, hMin );
    addPS( betaMin, hMax );
    addPS( betaMax, hMin );
    addPS( betaMax, hMax );
    return newPS;
  }

  def createSubTasks( table: Tables, targetNumRuns: Long ): ArrayList[Task] {
    val newTasks = new ArrayList[Task]();
    val newPSs = createParameterSets( table );
    for( ps in newPSs ) {
      val newRuns = ps.createRunsUpTo( table, targetNumRuns );
      for( run in newRuns ) {
        newTasks.add( run.generateTask() );
      }
    }
    return newTasks;
  }

  static def create( betaMin: Double, betaMax: Double, hMin: Double, hMax: Double ): Box {
    return new Box( betaMin, betaMax, hMin, hMax );
  }
}

