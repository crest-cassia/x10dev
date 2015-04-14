package tekram.util;
import x10.util.Random;

public class Brownian {
	
	var mu:Double;
	var sigma:Double;
	var dt:Double;
	var x0:Double;
	var x:Double;
	val random:Random;
	val gaussian:Gaussian;
	
	public def this(random:Random, mu:Double, sigma:Double, x0:Double, dt:Double) {
		this.random = random;
		this.gaussian = new Gaussian(random);
		this.mu = mu;
		this.sigma = sigma;
		this.x0 = x0;
		this.x = x0;
		this.dt = dt;
	}
	
	public def this(random:Random, mu:Double, sigma:Double) {
		this(random, mu, sigma, 0.0, 1.0);
	}
	
	public def this(mu:Double, sigma:Double) {
		this(new Random(), mu, sigma, 0.0, 1.0);
	}
	
	public def nextBrownian():Double {
		this.x += this.mu * this.dt + this.sigma * gaussian.nextGaussian() * dt * dt;
//		this.x += this.mu * this.dt + this.sigma * gaussian.nextGaussian() * Math.sqrt(this.dt);
		return this.x;
	}
	
	
	public static def main(Rail[String]) {
		val g = new Brownian(0.0, 1.0);
		for (val t in 1..1000) {
			Console.OUT.println(g.nextBrownian());
		}
	}
}
