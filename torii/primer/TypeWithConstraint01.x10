public class TypeWithConstraint01 {

	static type A[T] = T{self == 3};

	public static def main(Rail[String]) {
		val a:A[Long] = 3;
	}
}
