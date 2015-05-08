import x10.regionarray.Region;
import x10.io.File;
import x10.interop.Java;
import org.json.simple.*;


class Simulator {

  static struct InputParameters( mu: Double, sigma: Double ) {
    public def toString(): String {
      return "{ \"mu\": " + mu + ", \"sigma\": " + sigma + " }";
    }

    public def toJson(): String {
      return toString();
    }
  }

  static struct OutputParameters( duration: Double ) {

    static def parseFromJson( jsonPath: String ): OutputParameters {
      val input = new File(jsonPath);
      var json:String = "";
      for( line in input.lines() ) {
        json += line;
      }
      val o = JSONValue.parse(json) as JSONObject;
      val duration = o.get("duration") as Double;
      return OutputParameters( duration );
    }

    public def toString(): String {
      return "{ \"orderParameter\": " + orderParameter + " }";
    }
  }

  static def command( params: InputParameters, seed: Long ): String {
    return "python ../../mock/dummy_simulator.py " +
           params.mu + " " +
           params.sigma + " " +
           seed;
  }

  public static val numParams = 3;

  static def deregularize( point: Point{self.rank==numParams} ): InputParameters {
    val mu   = point(0) * 0.1;
    val sigma= point(1) * 0.1;
    return InputParameters( mu, sigma );
  }

  static def searchRegion(): Region{self.rank==numParams} {
    return Region.makeRectangular( 10..1000, 0..100, 0..10000 );
  }

}

