import x10.util.Stack;

public class Stack01 {
	
    public static def main(args:Rail[String]) {
    	val stack = new Stack[String]();
    	stack.push("a");
    	stack.push("b");
    	Console.OUT.println(stack);
    	val b = stack.pop();
    	Console.OUT.println(stack);
    }
}
