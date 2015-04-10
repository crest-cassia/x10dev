import x10.io.Console;
import x10.util.ArrayList;

public class Run {
  public val id: Long;
  public var placeId: Long;
  public var startAt: Long;
  public var finishAt: Long;
  val cmd: String;
  val seed: Long;
  public var result: Double;
  public var finished: Boolean;
  val parentPSId: Long;

  def this( _id:Long, _ps: ParameterSet ) {
    id = _id;
    parentPSId = _ps.id;
    seed = 12345; // TODO: IMPLEMENT ME
    cmd = generateCommand( _ps.beta, _ps.h );
    finished = false;
  }

  public def generateTask(): Task {
    val task = new Task( id, cmd );
    return task;
  }

  private def generateCommand( beta: Double, h: Double ): String {
    val cmd = "../../build/ising2d.out 99 100 " + beta + " " + h + " 10000 10000 " + seed;
    return cmd;
  }

  def getParentPSId(): Long {
    return parentPSId;
  }

  def storeResult( _result: Double, _placeId: Long, _startAt: Long, _finishAt: Long ) {
    result = _result;
    placeId = _placeId;
    startAt = _startAt;
    finishAt = _finishAt;
    finished = true;
  }

  def toString(): String {
    val str = "{ id: " + id + ", parentPSId: " + parentPSId + ", seed: " + seed +
              ", result: " + result +
              ", placeId: " + placeId + ", startAt: " + startAt + ", finishAt: " + finishAt + " }";
    return str;
  }

  def toJson(): String {
    val str = "{ \"id\": " + id + ", \"parentPSId\": " + parentPSId + ", \"seed\": " + seed +
              ", \"result\": " + result +
              ", \"placeId\": " + placeId + ", \"startAt\": " + startAt + ", \"finishAt\": " + finishAt + " }";
    return str;
  }
}
