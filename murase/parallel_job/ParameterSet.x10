import x10.io.Console;
import x10.util.ArrayList;
import x10.util.Pair;

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

  def numRuns(): Long {
    return runIds.size();
  }

  def runs( table: Tables ): ArrayList[Run] {
    val a = new ArrayList[Run]();
    for( runId in runIds ) {
      val run = table.runsTable.get( runId );
      a.add( run );
    }
    return a;
  }

  def createRuns( table: Tables, numRuns: Long ): ArrayList[Run] {
    val a = new ArrayList[Run]();
    for( i in 1..numRuns ) {
      val run = new Run( table.maxRunId, this );
      table.maxRunId += 1;
      table.runsTable.put( run.id, run );
      runIds.add( run.id );
      a.add( run );
    }
    return a;
  }

  def createRunsUpTo( table: Tables, targetNumRuns: Long ): ArrayList[Run] {
    val n = ( numRuns() < targetNumRuns ) ? ( targetNumRuns - numRuns() ) : 0;
    return createRuns( table, n );
  }

  def isFinished( table: Tables ): Boolean {
    for( run in runs( table ) ) {
      if( run.finished == false ) {
        return false;
      }
    }
    return true;
  }

  def averagedResult( table: Tables ): Double {
    var sum: Double = 0.0;
    val runs = runs( table );
    for( run in runs ) {
      sum += run.result;
    }
    return sum / runs.size();
  }

  static val tolerance: Double = 0.0000001;

  static def find( table: Tables, beta: Double, h: Double ): ParameterSet {
    for( entry in table.psTable.entries() ) {
      val ps = entry.getValue();
      val d_beta = ps.beta - beta;
      val d_h = ps.h - h;
      if( d_beta > - tolerance && d_beta < tolerance &&
          d_h > -tolerance && d_h < tolerance ) {
        return ps;
      }
    }
    return null;
  }

  static def findOrCreateParameterSet( table: Tables, beta: Double, h: Double ): ParameterSet {
    var ps: ParameterSet = find( table, beta, h );
    if( ps == null ) {
      ps = new ParameterSet( table.maxPSId, beta, h );
      table.maxPSId += 1;
      table.psTable.put( ps.id, ps );
    }
    return ps;
  }
}

