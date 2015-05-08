import x10.regionarray.*;

public class Region01 {

	public static def main(args:Rail[String]) {
		
		val x = 1..3;
		Console.OUT.println(x.typeName());

		val r0 = Region.make(1..3, 1..3);
		Console.OUT.println(r0);

		val r1 = Region.make([1..3, (1..3) as LongRange]);
		Console.OUT.println(r1);

		/* DOESNT WORK */
//		val r2 = Region.make([1..3, 1..3] as Rail[LongRange]);
//		Console.OUT.println(r2);

		val LR = new Rail[LongRange](2);
		LR(0) = 1..3;
		LR(1) = 1..3;

		val r3 = Region.make(LR);
		Console.OUT.println(r3);
	}
}
