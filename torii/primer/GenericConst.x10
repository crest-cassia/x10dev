public class GenericConst[T]{T<:Long} {

	public def this(T, ()=>T) {
	}

	public static def main(Rail[String]) {
		new GenericConst(1, ()=>2);
	}
}
