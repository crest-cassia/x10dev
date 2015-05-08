package tekram.marketattack;
import tekram.Agent;
import tekram.Market;
import tekram.Order;

public class MarketPriceAttack extends MarketAttack {
	
	public var market:Market;
	public var time:Long;
	public var priceImpact:Double;
	public var volumeImpact:Double;

	public def this(market:Market, time:Long, priceImpact:Double, volumeImpact:Double) {
		this.market = market;
		this.time = time;
		this.priceImpact = priceImpact;
		this.volumeImpact = volumeImpact;
		assert 0.0 <= priceImpact && priceImpact <= 2.0 : "0.0 <= priceImpact <= 2.0";
		assert 0.0 <= volumeImpact && volumeImpact <= 1.0 : "0.0 <= volumeImpact <= 1.0";
	}

	public def update():void {
		val market = this.market;
		val t = market.getTime();
		val agent = new Agent(-1);
		agent.setMarketAccessible(market);
		agent.setAssetVolume(market, Long.MAX_VALUE / 2); // Long.MAX_VALUE + 1 == LONG.MIN_VALUE;
		agent.setCashAmount(Double.MAX_VALUE / 2);
		if (t == this.time) {
			if (this.market.isRunning()) {
				if (this.priceImpact <= 1.0) {
					val basePrice = market.getSellOrderBook().getBestPrice();
					val orderPrice = basePrice * this.priceImpact;
					val volumeBetween = market.getBuyOrderBook().getTotalVolume((order:Order) => order.getPrice() >= orderPrice);
					val orderVolume = (volumeBetween * (1.0 + this.volumeImpact) + 1) as Long; // Execute all buy orders higher than that price and remain some impact.
					val timeLength = Long.MAX_VALUE / 2;
					val order = new Order(Order.KIND_SELL_LIMIT_ORDER, agent, market, orderPrice, orderVolume, timeLength);
					val dummy = new Order(Order.KIND_BUY_LIMIT_ORDER, agent, market, orderPrice, 1, timeLength);
					market.handleOrder(dummy);
					market.handleOrder(order);
					Console.OUT.println("# MARKET ATTACK: placed a sell order " + order + "(volume " + order.getVolume() + ")");
					if (orderVolume == 0) {
						Console.OUT.println("# MARKET ATTACK FAILED (maybe no order in the book)");
					}
				} else {
					val basePrice = market.getBuyOrderBook().getBestPrice();
					val orderPrice = basePrice * this.priceImpact;
					val volumeBetween = market.getSellOrderBook().getTotalVolume((order:Order) => order.getPrice() <= orderPrice);
					val orderVolume = (volumeBetween * (1.0 + this.volumeImpact) + 1) as Long; // Execute all sell orders lower than that price and remain some impact.
					val timeLength = Long.MAX_VALUE / 2;
					val order = new Order(Order.KIND_BUY_LIMIT_ORDER, agent, market, orderPrice, orderVolume, timeLength);
					val dummy = new Order(Order.KIND_SELL_LIMIT_ORDER, agent, market, orderPrice, 1, timeLength);
					market.handleOrder(dummy);
					market.handleOrder(order);
					Console.OUT.println("# MARKET ATTACK: placed a buy order " + order + "(volume " + order.getVolume() + ")");
					if (orderVolume == 0) {
						Console.OUT.println("# MARKET ATTACK FAILED (maybe no order in the book)");
					}
				}
			}
		}
	}
}
