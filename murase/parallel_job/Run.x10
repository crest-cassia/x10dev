import x10.util.ArrayList;

public class Run {
  public val id: Long;
  public var placeId: Long;
  public var startAt: Long = -1;
  public var finishAt: Long = -1;
  val params: Simulator.InputParameters;
  val seed: Int;
  public var result: Simulator.OutputParameters;
  public var finished: Boolean;
  val parentPSId: Long;

  def this( _id:Long, _ps: ParameterSet, _seed: Int ) {
    id = _id;
    parentPSId = _ps.id;
    seed = _seed;
    params = Simulator.deregularize( _ps.point );
    finished = false;
  }

  public def generateTask(): Task {
    val task = new Task( id, params, seed );
    return task;
  }

  /*
  private def generateCommand( input: Simulator.InputParameters ): String {
    val cmd = Simulator.command( input, seed );
    return cmd;
  }
  */

  def parameterSet( table: Tables ): ParameterSet {
    return table.psTable.get( parentPSId );
  }

  def storeResult( _result: Simulator.OutputParameters, _placeId: Long, _startAt: Long, _finishAt: Long ) {
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
