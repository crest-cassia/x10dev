import x10.util.StringUtil;

public class StringUtil01 {

	public static def main(Rail[String]) {
		Console.OUT.println(StringUtil.formatArray([1.0, 2.0, "A" as Any, 3.0, "NAOKI", "", ""], ",", "", Int.MAX_VALUE));
		Console.OUT.println(StringUtil.formatArray([1.0, 2.0, "A" as Any, 3.0, "NAOKI", "", ""], ",", "", Int.MAX_VALUE));
	}
}
