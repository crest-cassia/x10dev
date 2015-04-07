import x10.io.Console;
import x10.compiler.Native;

public class MySystem {

  @Native("c++", "system( (#1)->c_str() );")
  @Native("java", "JRuntime.exec(#1)")
  native public static def system(cmd:String):Int;

  public static def main(args:Rail[String]) {
    val rc = system("echo hello");
    Console.OUT.println(rc);
  }
}
