package tekram.marketattack;
import tekram.Market;
import tekram.util.MultiGeomBrownian; // TODO: will be replaced by tekram.Fundamentals.x10

public class FundamentalPriceAttack extends MarketAttack {

	public var fundamentals:MultiGeomBrownian;
	public var market:Market;
	public var time:Long;
	public var priceImpact:Double;
	public var originalState:Double; // For recovery.

	public def this(fundamentals:MultiGeomBrownian, market:Market, time:Long, priceImpact:Double) {
		this.fundamentals = fundamentals;
		this.market = market;
		this.time = time;
		this.priceImpact = priceImpact;
		this.originalState = Double.NaN;
		assert 0.0 <= priceImpact && priceImpact <= 2.0 : "0.0 <= priceImpact <= 2.0";
	}

	public def update():void {
		val market = this.market;
		val t = market.getTime();
		if (t == this.time) {
			if (market.isRunning()) {
				this.originalState = this.fundamentals.s0(market.id);
				this.fundamentals.s0(market.id) *= this.priceImpact;
			}
		}
	}
}
