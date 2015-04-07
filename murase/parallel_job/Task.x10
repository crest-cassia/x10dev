import x10.io.Console;
import x10.io.File;
import x10.interop.Java;
import org.json.simple.*;

public class Task {

  public val runId: Long;
  public val cmd: String;

  def this( _runId: Long, _cmd: String ) {
    runId = _runId;
    cmd = _cmd;
  }

  def run(): Double {
    val scriptPath = ShellScriptGenerator.generateScript( runId, cmd );
    Console.OUT.println( "  running : " + runId );
    val rc = MySystem.system( "bash " + scriptPath );
    Console.OUT.println( "  finished : " + scriptPath + " => " + rc );

    val result = parseOutputJson();
    return result;
  }
  
  def parseOutputJson(): Double {
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

  def toString(): String {
    return "{ runId : " + runId + ", cmd : " + cmd + " }";
  }
}
