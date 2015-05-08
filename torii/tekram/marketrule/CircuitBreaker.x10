package tekram.marketrule;
import x10.util.HashMap;
import x10.util.HashSet;
import x10.util.Set;
import tekram.Market;

public class CircuitBreaker extends MarketRule {

	public var market:Market;
	public var basePrice:Double;
	public var changeRate:Double;
	public var timeLength:Long;
	public var timeStarted:Long;
	public var activationCount:Long;
	public var activationCountMax:Long;
	public var companionMarkets:Set[Market];

	public def this(market:Market, basePrice:Double, changeRate:Double, timeLength:Long) {
		this.market = market;
		this.basePrice = basePrice;
		this.changeRate = changeRate;
		this.timeLength = timeLength;
		this.timeStarted = Long.MIN_VALUE;
		this.activationCount = 0;
		this.activationCountMax = Long.MAX_VALUE;
		this.companionMarkets = new HashSet[Market]();
	}

	public def update() {
		val market = this.market;
		val t = market.getTime();
		if (market.isRunning()) {
			if (this.activationCount >= this.activationCountMax) {
				return;
			}
			val priceChange = this.basePrice - market.getMarketPrice();
			val thresholdChange = this.basePrice * this.changeRate * (this.activationCount + 1); // More and more generous.
			if (Math.abs(priceChange) >= Math.abs(thresholdChange)) {
				/* REMARK: The current implementation assumes each market
				 * is associated with only one circuit breaker. Otherwise,
				 * the running-state switching makes crash. Use the technique
				 * of `reference counting` to resolve this matter if needed. */
				market.setRunning(false);
				for (companion in this.companionMarkets) {
					companion.setRunning(false);
				}
				this.timeStarted = t;
				this.activationCount++;
			}
		} else {
			if (t > this.timeStarted + this.timeLength) {
				market.setRunning(true);
				for (companion in this.companionMarkets) {
					companion.setRunning(true);
				}
				this.timeStarted = Long.MIN_VALUE;
			}
		}
	}

	public def setBasePrice(basePrice:Double) {
		this.basePrice = basePrice;
	}

	public def setActivationCountMax(activationCountMax:Long) {
		assert activationCountMax >= 0;
		this.activationCountMax = activationCountMax;
	}

	public def addCompanionMarket(market:Market) {
		this.companionMarkets.add(market);
	}
}
