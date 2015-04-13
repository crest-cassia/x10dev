import x10.io.Console;
import x10.util.HashMap;
import x10.util.ArrayList;

public class Box {
  public val psIds: ArrayList[Long] = new ArrayList[Long]();
  public val id: Long;
  public val betaMin: Double;
  public val betaMax: Double;
  public val hMin: Double;
  public val hMax: Double;

  def this(_id: Long, _betaMin:Double, _betaMax:Double, _hMin:Double, _hMax:Double) {
    id = _id;
    betaMin = _betaMin;
    betaMax = _betaMax;
    hMin = _hMin;
    hMax = _hMax;
  }

  def appendParameterSet( ps: ParameterSet ) {
    psIds.add( ps.id );
  }

  def toString(): String {
    val str = "{ id: " + id + "," +
               " betaMin: " + betaMin + "," +
               " betaMax: " + betaMax + "," +
               " hMin: " + hMin + "," +
               " hMax: " + hMax + "," +
               " psIds: " + psIds + " }";
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
}
