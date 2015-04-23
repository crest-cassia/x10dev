import x10.io.Console;
import x10.io.File;
import x10.interop.Java;
import x10.compiler.Native;
import org.json.simple.*;

struct Task( runId: Long, cmd: String) {

  public def run(): OutputParameters {
    val scriptPath = ShellScriptGenerator.generateScript( runId, cmd );
    Console.OUT.println( "  running : " + runId );
    val rc = system( "bash " + scriptPath );
    Console.OUT.println( "  finished : " + scriptPath + " => " + rc );

    val result = parseOutputJson();
    return result;
  }
  
  @Native("java", "JRuntime.exec(#1)")
  native private def system(cmd:String):Int;

  private def parseOutputJson(): OutputParameters {
    val jsonPath = runId + "/_output.json";
    return OutputParameters.parseFromJson( jsonPath );
  }

  public def toString(): String {
    return "{ runId : " + runId + ", cmd : " + cmd + " }";
  }
}
