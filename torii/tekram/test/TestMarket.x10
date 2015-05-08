package tekram.test;
import x10.util.Random;
import tekram.Agent;
import tekram.IndexMarket;
import tekram.Market;
import tekram.Order;
import tekram.OrderBook;
import tekram.marketindex.CapitalWeightedFundamentalIndex;
import tekram.marketindex.CapitalWeightedIndex;
import tekram.util.Gaussian;

/**
 * An implementation of a static non-evolving market, whose primary use
 * is currently limited for testing the order-making strategies.
 */
public class TestMarket {

	public static def init() {
	}

	public static def createTestMarket(id:Long):Market {
		val market = new Market(id);
		market.setInitialMarketPrice(300.0);
		market.setInitialFundamentalPrice(300.0);
		market.setOutstandingShares(10000);
		market.updateTime();
		return market;
	}

	public static def createTestIndexMarket(N:Long):IndexMarket {
		val market = new IndexMarket(N);
		for (i in 0..(N - 1)) {
			market.addMarket(createTestMarket(i));
		}
		val marketIndex = new CapitalWeightedIndex();
		marketIndex.normal = 300.0;
		marketIndex.scale = 300.0;
		market.setMarketIndexMethod(marketIndex);

		val fundamentalIndex = new CapitalWeightedFundamentalIndex();
		fundamentalIndex.normal = 300.0;
		fundamentalIndex.scale = 300.0;

		market.setInitialMarketPrice(300.0);
		market.setInitialFundamentalPrice(300.0);
		market.setOutstandingShares(10000);
		market.updateTime();
		return market;
	}

	public static def placeRandomOrders(market:Market, N:Long) {
		val random = new Random();
		val gaussian = new Gaussian(random);

		val agent = new Agent(-1);
		agent.setMarketAccessible(market);

		val marketPrice = market.getMarketPrice();

		for (i in 0..(N - 1)) {
			var r:Double;
			do {
				r = gaussian.nextGaussian() * 0.1 + 1.0;
			} while (r <= 0.0);
			if (r < 1.0) {
				val volume = random.nextLong(10) + 1;
				val timeLength = random.nextLong(100) + 1;
				market.handleOrder(new Order(Order.KIND_BUY_LIMIT_ORDER, agent, market, marketPrice * r, volume, timeLength));
			}
			if (r > 1.0) {
				val volume = random.nextLong(10) + 1;
				val timeLength = random.nextLong(100) + 1;
				market.handleOrder(new Order(Order.KIND_SELL_LIMIT_ORDER, agent, market, marketPrice * r, volume, timeLength));
			}
		}
	}

	public static def dumpOrderBooks(market:Market) {
		Console.OUT.println("# MARKET (id " + market.id + ")");
		market.getSellOrderBook().dump(OrderBook.HIGHERS_FIRST);
		market.getBuyOrderBook().dump(OrderBook.HIGHERS_FIRST);
	}

	public static def test_dumpOrderBooks() {
		val index = createTestIndexMarket(2);
		val spots = index.getMarkets();

		placeRandomOrders(index, 50);
		for (m in spots) {
			placeRandomOrders(m, 50);
		}

		dumpOrderBooks(index);
		for (m in spots) {
			dumpOrderBooks(m);
		}
	}

	public static def test_emulateOrder() {

		val market = createTestMarket(0);
		placeRandomOrders(market, 50);
		val marketPrice = market.getMarketPrice();

		val agent = new Agent(-1);
		agent.setMarketAccessible(market);

		Console.OUT.println(market.lastExecutedPrices.getLast()); // NaN

		val p1 = market.emulateOrder(new Order(Order.KIND_SELL_LIMIT_ORDER, agent, market, marketPrice / 2, 1, 10));
		val p2 = market.emulateOrder(new Order(Order.KIND_SELL_LIMIT_ORDER, agent, market, marketPrice * 1, 1, 10));
		val p3 = market.emulateOrder(new Order(Order.KIND_SELL_LIMIT_ORDER, agent, market, marketPrice * 2, 1, 10));
		Console.OUT.println([p1, p2, p3]);

		val p5 = market.emulateOrder(new Order(Order.KIND_BUY_LIMIT_ORDER, agent, market, marketPrice / 2, 1, 10));
		val p6 = market.emulateOrder(new Order(Order.KIND_BUY_LIMIT_ORDER, agent, market, marketPrice * 1, 1, 10));
		val p7 = market.emulateOrder(new Order(Order.KIND_BUY_LIMIT_ORDER, agent, market, marketPrice * 2, 1, 10));
		Console.OUT.println([p5, p6, p7]);

		Console.OUT.println(market.lastExecutedPrices.getLast()); // NaN
	}

	public static def main(args:Rail[String]) {
		val T = true;
		val F = false;
		if (F) test_dumpOrderBooks();
		if (F) test_emulateOrder();
	}
}

