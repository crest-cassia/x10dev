import x10.io.File;
import x10.interop.Java;
import org.json.simple.*;

struct OutputParameters( orderParameter: Double ) {

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
