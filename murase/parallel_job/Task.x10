import x10.io.File;
// import x10.interop.Java;
import x10.compiler.Native;
import x10.util.Timer;
// import org.json.simple.*;
// import java.util.logging.Logger;
// import java.util.logging.Level;

struct Task( runId: Long, params: Simulator.InputParameters, seed: Long) {

  public def run(): Simulator.OutputParameters {
    /*
    val scriptPath = ShellScriptGenerator.generateScript( runId, cmd );
    val rc = system( "bash " + scriptPath );
    val result = parseOutputJson();
    */
    val result = Simulator.run( params, seed );
    // val result = Simulator.OutputParameters( 3.0 );
    return result;
  }
  
  public def toString(): String {
    return "{ runId : " + runId + ", params : " + params + ", seed: " + seed + " }";
  }
}
