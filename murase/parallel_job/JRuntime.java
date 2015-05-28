import java.io.*;
class JRuntime {
  public static int exec(String cmd) {
    try{
      Process proc = Runtime.getRuntime().exec(cmd);
      // BufferedReader in = new BufferedReader(new InputStreamReader(proc.getInputStream()));
      // String line;
      // while((line=in.readLine())!=null)  {
      //   System.out.println(line);
      // }
      proc.waitFor();
      return proc.exitValue();
    }catch(IOException e){
      System.out.println("fail: "+cmd);
      e.printStackTrace(System.out);
    }catch(InterruptedException e) {
      System.out.println("fail: "+cmd);
      e.printStackTrace(System.out);
    }
    return 1;
  }
}
