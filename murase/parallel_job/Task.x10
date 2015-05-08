import x10.io.Console;
import x10.io.File;
import x10.interop.Java;
import x10.compiler.Native;
import org.json.simple.*;
import java.util.logging.Logger;
import java.util.logging.Level;

struct Task( runId: Long, cmd: String) {

  public def run(): Simulator.OutputParameters {
    val scriptPath = ShellScriptGenerator.generateScript( runId, cmd );
    val logger = Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);
    logger.fine( "  running : " + runId );
    val rc = system( "bash " + scriptPath );
    logger.fine( "  finished : " + scriptPath + " => " + rc );

    val result = parseOutputJson();
    return result;
  }
  
  @Native("java", "JRuntime.exec(#1)")
  native private def system(cmd:String):Int;

  private def parseOutputJson(): Simulator.OutputParameters {
    val jsonPath = runId + "/_output.json";
    return Simulator.OutputParameters.parseFromJson( jsonPath );
  }

  public def toString(): String {
    return "{ runId : " + runId + ", cmd : " + cmd + " }";
  }
}
