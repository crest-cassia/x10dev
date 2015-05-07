import x10.regionarray.Region;
import x10.io.File;
import x10.interop.Java;
import org.json.simple.*;


class Simulator {

  static struct InputParameters( beta: Double, h: Double, l: Long ) {
    public def toString(): String {
      return "{ \"beta\": " + beta + ", \"h\": " + h + " }";
    }

    public def toJson(): String {
      return toString();
    }
  }

  static struct OutputParameters( orderParameter: Double ) {

    static def parseFromJson( jsonPath: String ): OutputParameters {
      Console.OUT.println( "  parsing : " + jsonPath );
      val input = new File(jsonPath);
      var json:String = "";
      for( line in input.lines() ) {
        json += line;
      }
      val o = JSONValue.parse(json) as JSONObject;
      val orderParameter = o.get("order_parameter") as Double;
      Console.OUT.println( orderParameter );
      return OutputParameters( orderParameter );
    }

    public def toString(): String {
      return "{ \"orderParameter\": " + orderParameter + " }";
    }
  }

  static def command( params: InputParameters, seed: Long ): String {
    return "../../build/ising2d.out " +
           (params.l-1) + " " +
           params.l + " " +
           params.beta + " " +
           params.h + " " +
           "10000 10000 " +
           seed;
  }

  public static val numParams = 2;

  static def deregularize( point: Point{self.rank==numParams} ): InputParameters {
    val beta = point(0) * 0.01;
    val h    = point(1) * 0.01;
    val lx   = 100;
    return InputParameters( beta, h, lx );
  }

  static def searchRegion(): Region{self.rank==numParams} {
    return Region.makeRectangular( 20..50, -100..100 );
  }

}

