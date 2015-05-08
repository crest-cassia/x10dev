package tekram.agent;
import x10.util.ArrayList;
import x10.util.List;
import tekram.Agent;
import tekram.IndexMarket;
import tekram.Market;
import tekram.Order;
import tekram.OrderBook;

import tekram.test.TestMarket;

public class BidAskArbitrageAgent extends ArbitrageAgent {

	public var orderMinVolume:Long;
	public var orderThresholdPrice:Double;
	public var orderTimeLength:Long;
	public var isShortSellingAllowed:Boolean;

	public def this(id:Long) {
		super(id);
		this.orderMinVolume = 1;
		this.orderThresholdPrice = 0.0;
		this.orderTimeLength = 2; // An order's lifetime; no rationale.
		this.isShortSellingAllowed = true;
	}

	static def getSumOfBestAskPrices(markets:List[Market]):Double {
		var sum:Double = 0.0;
		for (m in markets) {
			sum += m.getSellOrderBook().getBestPrice();
		}
		return sum;
	}

	static def getSumOfBestBidPrices(markets:List[Market]):Double {
		var sum:Double = 0.0;
		for (m in markets) {
			sum += m.getBuyOrderBook().getBestPrice();
		}
		return sum;
	}

	static def getSumOfKBestPrices(orders:List[Order], k:Long):Double {
		var sum:Double = 0.0;
		var i:Long = 0;
		for (order in orders) {
			val n = Math.min(k - i, order.getVolume());
			sum += order.getPrice() * n;
			i += n;
			if (i >= k) {
				return sum;
			}
		}
		return Double.NaN;
	}

	public def placeOrders(market:Market):List[Order] {
		assert market instanceof IndexMarket;
		val orders = new ArrayList[Order]();

		val index = market as IndexMarket;
		val spots = index.getMarkets();
		if (!index.isRunning()) {
			return orders; // Stop thinking.
		}
		for (m in spots) {
			if (!m.isRunning()) {
				return orders; // Stop thinking.
			}
		}

		assert this.orderMinVolume == 1 : "this.orderMinVolume == 1";

		// TODO: BisectQueue???
		val indexSellOrders = index.getSellOrderBook().toList();
		indexSellOrders.sort(OrderBook.LOWERS_FIRST);
		val indexBuyOrders = index.getBuyOrderBook().toList();
		indexBuyOrders.sort(OrderBook.HIGHERS_FIRST);

		val spotAskSum = getSumOfBestAskPrices(spots);
		val spotBidSum = getSumOfBestBidPrices(spots);
		val indexKAskSum = getSumOfKBestPrices(indexSellOrders, spots.size());
		val indexKBidSum = getSumOfKBestPrices(indexBuyOrders, spots.size());

		if (false) {
			Console.OUT.println("spotAskSum " + spotAskSum);
			Console.OUT.println("spotBidSum " + spotBidSum);
			Console.OUT.println("indexKAskSum " + indexKAskSum);
			Console.OUT.println("indexKBidSum " + indexKBidSum);
		}

		if (spotAskSum.isNaN() || spotBidSum.isNaN()) {
			return orders; // Stop thinking.
		}
		if (indexKAskSum.isNaN() || indexKBidSum.isNaN()) {
			return orders; // Stop thinking.
		}

		if (indexKAskSum < spotBidSum && spotBidSum - indexKAskSum > this.orderThresholdPrice) {
			val n = this.orderMinVolume;
			val N = spots.size() * n;

			var i:Long = 0;
			for (order in indexSellOrders) {
				val volume = Math.min(N - i, order.getVolume());
				orders.add(new Order(Order.KIND_BUY_LIMIT_ORDER, this, index, order.getPrice(), volume, this.orderTimeLength));
				i += volume;
				if (i >= N) {
					break;
				}
			}
			for (m in spots) {
				orders.add(new Order(Order.KIND_SELL_LIMIT_ORDER, this, m, m.getBuyOrderBook().getBestPrice(), n, this.orderTimeLength));
			}
		}
		if (indexKBidSum > spotAskSum && indexKBidSum - spotAskSum > this.orderThresholdPrice) {
			val n = this.orderMinVolume;
			val N = spots.size() * n;

			var i:Long = 0;
			for (order in indexBuyOrders) {
				val volume = Math.min(N - i, order.getVolume());
				orders.add(new Order(Order.KIND_SELL_LIMIT_ORDER, this, index, order.getPrice(), volume, this.orderTimeLength));
				i += volume;
				if (i >= N) {
					break;
				}
			}
			for (m in spots) {
				orders.add(new Order(Order.KIND_BUY_LIMIT_ORDER, this, m, m.getSellOrderBook().getBestPrice(), n, this.orderTimeLength));
			}
		}
		return orders;
	}



	public static def main(args:Rail[String]) {
		TestMarket.init();

		val index = TestMarket.createTestIndexMarket(2);
		val spots = index.getMarkets();

		TestMarket.placeRandomOrders(index, 50);
		for (m in spots) {
			TestMarket.placeRandomOrders(m, 50);
		}

		TestMarket.dumpOrderBooks(index);
		for (m in spots) {
			TestMarket.dumpOrderBooks(m);
		}

		if (false) {
			// The case if indexKAskSum < spotBidSum.
			index.getSellOrderBook().getBestPricedOrder().price = 290.0;
		}
		if (false) {
			// The case if indexKBidSum > spotAskSum
			index.getBuyOrderBook().getBestPricedOrder().price = 310.0;
		}

		val agent = new BidAskArbitrageAgent(0);

		Console.OUT.println("BidAskArbitrageAgent");
		val orders = agent.placeOrders(index);
		Console.OUT.println("orders.size() " + orders.size());
		OrderBook.dump(orders);
	}
}

