package plham.event;
import x10.util.HashSet;
import x10.util.List;
import x10.util.Set;
import plham.Market;
import plham.Order;

/**
 * A trading halt is a market regulation that suspends the trading of some assets.
 * The current implementation sets <code>Market#isRunning() = false</code> when the price changed beyond the prespecified threshold range.
 */
public class TradingHaltRule implements Market.MarketEvent, Market.OrderEvent {

	public var referenceMarketId:Long;
	public var referencePrice:Double;
	public var triggerChangeRate:Double;
	public var haltingTimeLength:Long;
	public var haltingTimeStarted:Long;
	public var activationCount:Long;
	public var targetMarketIds:Set[Long];    // Use referenceMarket.id ?

	public def this() {
//		this.referenceMarketId = referenceMarket.id;
//		this.referencePrice = referencePrice;
//		this.triggerChangeRate = triggerChangeRate;
//		this.haltingTimeLength = haltingTimeLength;
		this.haltingTimeStarted = Long.MIN_VALUE;
		this.activationCount = 0;
		this.targetMarketIds = new HashSet[Long]();
	}

	/**
	 * (The order will be ignored.)
	 */
	public def update(market:Market, order:Order) {
		this.update(market);
	}

	public def update(market:Market) {
		assert this.referenceMarketId == market.id;
		val referenceMarket = market;
		val env = market.env;
		val t = referenceMarket.getTime();
		if (referenceMarket.isRunning()) {
			val priceChange = this.referencePrice - referenceMarket.getPrice();
			val thresholdChange = this.referencePrice * this.triggerChangeRate * (this.activationCount + 1);
			if (Math.abs(priceChange) >= Math.abs(thresholdChange)) {
				/* REMARK: The current implementation assumes each referenceMarket
				 * is associated with only one circuit breaker. Otherwise,
				 * the running-state switching makes crash. Use the technique
				 * of `reference counting` to resolve this matter if needed. */
				referenceMarket.setRunning(false);
				for (i in this.targetMarketIds) {
					val target = env.markets(i);
					target.setRunning(false);
				}
				this.haltingTimeStarted = t;
				this.activationCount++;
			}
		} else {
			if (t > this.haltingTimeStarted + this.haltingTimeLength) {
				referenceMarket.setRunning(true);
				for (i in this.targetMarketIds) {
					val target = env.markets(i);
//					target.cleanOrderBooks(target.getPrice()); // Better to use Itayose.
					target.itayoseOrderBooks();
					target.setRunning(true);
				}
				this.haltingTimeStarted = Long.MIN_VALUE;
			}
		}
	}

	public def setReferencePrice(referencePrice:Double) {
		this.referencePrice = referencePrice;
	}

	public def addTargetMarket(market:Market) {
		this.targetMarketIds.add(market.id);
	}

	public def addTargetMarkets(markets:List[Market]) {
		for (market in markets) {
			this.targetMarketIds.add(market.id);
		}
	}
}
