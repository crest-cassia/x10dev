import x10.io.Console;
import x10.util.ArrayList;
import x10.util.Pair;

public class ParameterSet( id: Long, point: Point{self.rank==Simulator.numParams} ) {
  val parentBoxIds: ArrayList[Long] = new ArrayList[Long]();
  public val runIds: ArrayList[Long] = new ArrayList[Long]();

  def getParentBoxIds(): ArrayList[Long] {
    return parentBoxIds;
  }

  def toString(): String {
    val str = "{ id: " + id + ", point: " + point + ", params: " + Simulator.deregularize(point) + " }";
    return str;
  }

  def toJson(): String {
    val str = "{ " +
                "\"id\": " + id +
                ", \"point\": " + point.toString() +
                ", \"params\": " + Simulator.deregularize(point).toJson() +
              " }";
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
      val run = new Run( table.maxRunId, this, table.nextSeed() );
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
      sum += run.result.normalize()(0);  // TODO: check other results
    }
    return sum / runs.size();
  }

  def isSimilarToWithRespectTo( another: ParameterSet, axis: Long ): Boolean {
    val d = point - another.point;
    for( i in 0..(d.rank-1) ) {
      if( i != axis && d(i) != 0 ) {
        return false;
      }
    }
    return true;
  }

  static val tolerance: Double = 0.0000001;

  static def find( table: Tables, p: Point{self.rank==Simulator.numParams} ): ParameterSet {
    for( entry in table.psTable.entries() ) {
      val ps = entry.getValue();
      if( ps.point.equals( p ) ) {
        return ps;
      }
    }
    return null;
  }

  static def findOrCreateParameterSet( table: Tables, p: Point{self.rank==Simulator.numParams} ): ParameterSet {
    var ps: ParameterSet = find( table, p );
    if( ps == null ) {
      ps = new ParameterSet( table.maxPSId, p );
      table.maxPSId += 1;
      table.psTable.put( ps.id, ps );
    }
    return ps;
  }
}

