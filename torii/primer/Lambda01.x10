
class Lambda01 {
	public static def main(Rail[String]) {
//		val println = (o:Any) => Console.OUT.println(o);                 // WRONG
//		val println = (o:Any) => { Console.OUT.println(o) };             // WRONG
		val println = (o:Any) => { Console.OUT.println(o); };            // OK
//		val println = (o:Any) => { Console.OUT.println(o); 0; };         // WRONG
//		val println = (o:Any) => { Console.OUT.println(o); return 0; };  // OK
//		val println = (o:Any) => { Console.OUT.println(o); 0 };          // OK
		println(12);
	}
}
