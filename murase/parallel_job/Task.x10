import x10.io.Console;
import x10.io.File;
import x10.interop.Java;
import x10.compiler.Native;
import org.json.simple.*;

struct Task( runId: Long, cmd: String) {

  public def run(): Double {
    val scriptPath = ShellScriptGenerator.generateScript( runId, cmd );
    Console.OUT.println( "  running : " + runId );
    val rc = system( "bash " + scriptPath );
    Console.OUT.println( "  finished : " + scriptPath + " => " + rc );

    val result = parseOutputJson();
    return result;
  }
  
  @Native("java", "JRuntime.exec(#1)")
  native private def system(cmd:String):Int;

  private def parseOutputJson(): Double {
    val jsonPath = runId + "/_output.json";
    Console.OUT.println( "  parsing : " + jsonPath );
    val input = new File(jsonPath);
    var json:String = "";
    for( line in input.lines() ) {
      json += line;
    }
    val o = JSONValue.parse(json) as JSONObject;
    val order_parameter = o.get("order_parameter") as Double;
    Console.OUT.println(order_parameter);
    return order_parameter;
  }

  public def toString(): String {
    return "{ runId : " + runId + ", cmd : " + cmd + " }";
  }
}
