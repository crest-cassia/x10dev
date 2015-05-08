package tekram.agent;
import x10.util.ArrayList;
import x10.util.List;
import x10.util.Random;
import tekram.Agent;
import tekram.IndexMarket;
import tekram.Global;
import tekram.Market;
import tekram.Order;
import tekram.util.Statistics;

public class AlterMiddleArbitrageAgent extends MiddleArbitrageAgent {

	public def this(id:Long) {
		super(id);
	}

	public def placeOrders(market:Market):List[Order] {
		assert market instanceof IndexMarket;
		val random = new Random();
		val orders = new ArrayList[Order]();

		val index = market as IndexMarket;
		val spots = index.getMarkets();
		val spotsRunning = new ArrayList[Market]();
		for (m in spots) {
			if (m.isRunning()) {
				spotsRunning.add(m);
			}
		}

		val timeLength = 2;

		val marketIndex = index.getMarketIndex();
		val marketPrice = index.getMarketPrice();

		if (marketPrice < marketIndex && marketIndex - marketPrice > this.orderThresholdPrice) {
			val n = this.orderMinVolume;
			val N = spots.size() * n;

			if (this.isShortSellingAllowed) {
				orders.add(new Order(Order.KIND_BUY_LIMIT_ORDER, this, index, index.getMarketPrice(), N, timeLength));
				for (m in spots) {
					if (m.isRunning()) {
						orders.add(new Order(Order.KIND_SELL_LIMIT_ORDER, this, m, m.getMarketPrice(), n, timeLength));
					} else {
						val condition = (x:Market)=> index.getWeightedMarketPrice(x) >= index.getWeightedMarketPrice(m);
						val a = this.chooseAlternativeMarket(spotsRunning, m, condition);
						if (a != null) {
							orders.add(new Order(Order.KIND_SELL_LIMIT_ORDER, this, a, a.getMarketPrice(), n, timeLength));
						} else {
							orders.clear();
							break;
						}
					}
				}
			} else {
				var hasAssetsNeeded:Boolean = true;
				var cashNeeded:Double = 0.0;
				orders.add(new Order(Order.KIND_BUY_LIMIT_ORDER, this, index, index.getMarketPrice(), N, timeLength));
				cashNeeded += index.getMarketPrice() * N;
				for (m in spots) {
					if (m.isRunning()) {
						orders.add(new Order(Order.KIND_SELL_LIMIT_ORDER, this, m, m.getMarketPrice(), n, timeLength));
						hasAssetsNeeded = (hasAssetsNeeded && this.getAssetVolume(m) >= n);
					} else {
						val condition = (x:Market)=> index.getWeightedMarketPrice(x) >= index.getWeightedMarketPrice(m);
						val a = this.chooseAlternativeMarket(spotsRunning, m, condition);
						if (a != null) {
							orders.add(new Order(Order.KIND_SELL_LIMIT_ORDER, this, a, a.getMarketPrice(), n, timeLength));
							hasAssetsNeeded = (hasAssetsNeeded && this.getAssetVolume(a) >= n);
						} else {
							orders.clear();
							hasAssetsNeeded = false;
							break;
						}
					}
				}
				if (cashNeeded > this.getCashAmount() || !hasAssetsNeeded) {
					orders.clear();
				}
			}
		}
		if (marketPrice > marketIndex && marketPrice - marketIndex > this.orderThresholdPrice) {
			val n = this.orderMinVolume;
			val N = spots.size() * n;

			if (this.isShortSellingAllowed) {
				orders.add(new Order(Order.KIND_SELL_LIMIT_ORDER, this, index, index.getMarketPrice(), N, timeLength));
				for (m in spots) {
					if (m.isRunning()) {
						orders.add(new Order(Order.KIND_BUY_LIMIT_ORDER, this, m, m.getMarketPrice(), n, timeLength));
					} else {
						val condition = (x:Market)=> index.getWeightedMarketPrice(x) <= index.getWeightedMarketPrice(m);
						val a = this.chooseAlternativeMarket(spotsRunning, m, condition);
						if (a != null) {
							orders.add(new Order(Order.KIND_BUY_LIMIT_ORDER, this, a, a.getMarketPrice(), n, timeLength));
						} else {
							orders.clear();
							break;
						}
					}
				}
			} else {
				var hasAssetsNeeded:Boolean = true;
				var cashNeeded:Double = 0.0;
				orders.add(new Order(Order.KIND_SELL_LIMIT_ORDER, this, index, index.getMarketPrice(), N, timeLength));
				hasAssetsNeeded = (hasAssetsNeeded && this.getAssetVolume(index) >= N);
				for (m in spots) {
					if (m.isRunning()) {
						orders.add(new Order(Order.KIND_BUY_LIMIT_ORDER, this, m, m.getMarketPrice(), n, timeLength));
						cashNeeded += m.getMarketPrice() * n;
					} else {
						val condition = (x:Market)=> index.getWeightedMarketPrice(x) <= index.getWeightedMarketPrice(m);
						val a = this.chooseAlternativeMarket(spotsRunning, m, condition);
						if (a != null) {
							orders.add(new Order(Order.KIND_BUY_LIMIT_ORDER, this, a, a.getMarketPrice(), n, timeLength));
							cashNeeded += a.getMarketPrice() * n;
						} else {
							orders.clear();
							hasAssetsNeeded = false;
							break;
						}
					}
				}
				if (cashNeeded > this.getCashAmount() || !hasAssetsNeeded) {
					orders.clear();
				}
			}
		}
		return orders;
	}

	public def chooseAlternativeMarket(markets:List[Market], original:Market, condition:(Market)=>Boolean) {
		val options = new ArrayList[Market]();
		val weights = new ArrayList[Double]();
		for (m in markets) {
			if (m != original && condition(m)) {
				options.add(m);
				weights.add(1.0 / Math.abs(m.getMarketPrice() - original.getMarketPrice()));
			}
		}
		if (options.size() == 0) {
			return null;
		}
		val i = Statistics.roulette(weights);
		return options(i);
	}
}

