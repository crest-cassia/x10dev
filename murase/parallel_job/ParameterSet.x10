import x10.io.Console;
import x10.util.ArrayList;

public class ParameterSet {
  public val id: Long;
  public val beta: Double;
  public val h: Double;
  val parentBoxIds: ArrayList[Long] = new ArrayList[Long]();
  public val runIds: ArrayList[Long] = new ArrayList[Long]();

  def this( _id:Long, _beta: Double, _h:Double ) {
    id = _id;
    beta = _beta;
    h = _h;
  }

  def pushParentBoxId(box_id: Long): void {
    parentBoxIds.add( box_id );
  }

  def getParentBoxIds(): ArrayList[Long] {
    return parentBoxIds;
  }

  def toString(): String {
    val str = "{ id: " + id + ", beta: " + beta + ", h: " + h + " }";
    return str;
  }

  def toJson(): String {
    val str = "{ \"id\": " + id + ", \"beta\": " + beta + ", \"h\": " + h + " }";
    return str;
  }
}
