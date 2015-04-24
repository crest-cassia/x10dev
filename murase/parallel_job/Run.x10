import x10.io.Console;
import x10.util.ArrayList;

public class Run {
  public val id: Long;
  public var placeId: Long;
  public var startAt: Long;
  public var finishAt: Long;
  val cmd: String;
  val seed: Int;
  public var result: OutputParameters;
  public var finished: Boolean;
  val parentPSId: Long;

  def this( _id:Long, _ps: ParameterSet, _seed: Int ) {
    id = _id;
    parentPSId = _ps.id;
    seed = _seed;
    cmd = generateCommand( _ps.params );
    finished = false;
  }

  public def generateTask(): Task {
    val task = new Task( id, cmd );
    return task;
  }

  private def generateCommand( input: InputParameters ): String {
    val cmd = Simulator.command( input, seed );
    Console.OUT.println( cmd );
    return cmd;
  }

  def parameterSet( table: Tables ): ParameterSet {
    return table.psTable.get( parentPSId );
  }

  def storeResult( _result: OutputParameters, _placeId: Long, _startAt: Long, _finishAt: Long ) {
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
