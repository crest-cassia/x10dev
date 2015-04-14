package tekram.util;
import x10.util.Random;

public class GeomBrownian extends Brownian {
	
	var s0:Double;
	
	public def this(random:Random, mu:Double, sigma:Double, s0:Double, dt:Double) {
		super(random, mu, sigma, 0.0, dt);
//		super(random, mu - (sigma * sigma) / 2.0, sigma, 0.0, dt);
		this.s0 = s0;
	}
	
	public def this(random:Random, mu:Double, sigma:Double, s0:Double) {
		this(random, mu, sigma, s0, 1.0);
//		this(random, mu, sigma, 1.0, 1.0);
	}
	
	public def this(mu:Double, sigma:Double, s0:Double) {
		this(new Random(), mu, sigma, s0, 1.0);
//		this(new Random(), mu, sigma, 1.0, 1.0);
	}
	
	public def nextBrownian():Double {
		return this.s0 * Math.exp(super.nextBrownian());
	}
	
	public static def main(Rail[String]) {
		val b = new GeomBrownian(new Random(), 0.0, 0.001, 300.0, 1.0);
		for (val t in 1..10000) {
			Console.OUT.println(b.nextBrownian());
		}
	}
}
