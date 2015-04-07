import x10.io.Console;
import x10.util.HashMap;
import x10.util.ArrayList;

public class Box {
  public val runIds: ArrayList[Long] = new ArrayList[Long]();
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

  def appendRun( run: Run ) {
    runIds.add( run.id );
  }

  def toString(): String {
    val str = "{ id: " + id + "," +
               " betaMin: " + betaMin + "," +
               " betaMax: " + betaMax + "," +
               " hMin: " + hMin + "," +
               " hMax: " + hMax + "," +
               " runIds: " + runIds + " }";
    return str;
  }
}
