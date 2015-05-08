package tekram.test;
import x10.util.ArrayList;
import x10.util.List;

public class List04 {

	static class A {
		public def h() {
			Console.OUT.println(this);
		}
	}

	static class B extends A {
	}

	static def f(a:List[A]) {
		val t = a(0);
		t.h();
	}

	static def g[T](a:List[T]){T<:A} {
		val t = a(0);
		t.h();
	}

	public static def main(Rail[String]) {
		val a = new ArrayList[A]();
		a.add(new A());
		val b = new ArrayList[B]();
		b.add(new B());

//		f(a); // NOT(Java) OK(C++)
		f(a as List[A]); // OK
//		f(b); // NOT
//		f(b as List[B]); // NOT
//		f(b as List[A]); // NOT
		
		g(a); // OK
		g(a as List[A]); // OK
		g(b); // OK
		g(b as List[B]); // OK
//		g(b as List[A]); // NOT

	}
}
