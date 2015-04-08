import x10.io.Console;
import x10.util.ArrayList;

public class Run {
  public val id: Long;
  public var placeId: Long;
  public var startAt: Long;
  public var finishAt: Long;
  public val beta: Double;
  public val h: Double;
  val seed: Long;
  public var result: Double;
  public var finished: Boolean;
  val parentBoxIds: ArrayList[Long] = new ArrayList[Long]();

  def this( _id:Long, _beta: Double, _h:Double ) {
    id = _id;
    beta = _beta;
    h = _h;

    seed = 12345; // TODO: IMPLEMENT ME

    finished = false;
  }

  public def generateTask(): Task {
    val task = new Task(id, generateCommand() );
    return task;
  }

  def pushParentBoxId(box_id: Long): void {
    parentBoxIds.add( box_id );
  }

  def generateCommand(): String {
    val cmd = "../../build/ising2d.out 99 100 " + beta + " " + h + " 10000 10000 " + seed;
    return cmd;
  }

  def storeResult( _result: Double, _placeId: Long, _startAt: Long, _finishAt: Long ) {
    result = _result;
    placeId = _placeId;
    startAt = _startAt;
    finishAt = _finishAt;
    finished = true;
  }

  def getParentBoxIds(): ArrayList[Long] {
    return parentBoxIds;
  }

  def toString(): String {
    val str = "{ id: " + id + ", beta: " + beta + ", h: " + h + ", seed: " + seed +
              ", result: " + result +
              ", placeId: " + placeId + ", startAt: " + startAt + ", finishAt: " + finishAt + " }";
    return str;
  }
}
