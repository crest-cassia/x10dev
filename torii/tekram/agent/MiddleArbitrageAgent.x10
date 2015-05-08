package tekram.agent;
import x10.util.ArrayList;
import x10.util.List;
import tekram.Agent;
import tekram.IndexMarket;
import tekram.Market;
import tekram.Order;

public class MiddleArbitrageAgent extends ArbitrageAgent {

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

		val marketIndex = index.getMarketIndex();
		val marketPrice = index.getMarketPrice();

		if (marketPrice < marketIndex && marketIndex - marketPrice > this.orderThresholdPrice) {
			val n = this.orderMinVolume;
			val N = spots.size() * n;

			if (this.isShortSellingAllowed) {
				orders.add(new Order(Order.KIND_BUY_LIMIT_ORDER, this, index, index.getMarketPrice(), N, this.orderTimeLength));
				for (m in spots) {
					orders.add(new Order(Order.KIND_SELL_LIMIT_ORDER, this, m, m.getMarketPrice(), n, this.orderTimeLength));
				}
			} else {
				var hasAssetsNeeded:Boolean = true;
				var cashNeeded:Double = 0.0;
				orders.add(new Order(Order.KIND_BUY_LIMIT_ORDER, this, index, index.getMarketPrice(), N, this.orderTimeLength));
				cashNeeded += index.getMarketPrice() * N;
				for (m in spots) {
					orders.add(new Order(Order.KIND_SELL_LIMIT_ORDER, this, m, m.getMarketPrice(), n, this.orderTimeLength));
					hasAssetsNeeded = (hasAssetsNeeded && this.getAssetVolume(m) >= n);
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
				orders.add(new Order(Order.KIND_SELL_LIMIT_ORDER, this, index, index.getMarketPrice(), N, this.orderTimeLength));
				for (m in spots) {
					orders.add(new Order(Order.KIND_BUY_LIMIT_ORDER, this, m, m.getMarketPrice(), n, this.orderTimeLength));
				}
			} else {
				var hasAssetsNeeded:Boolean = true;
				var cashNeeded:Double = 0.0;
				orders.add(new Order(Order.KIND_SELL_LIMIT_ORDER, this, index, index.getMarketPrice(), N, this.orderTimeLength));
				hasAssetsNeeded = (hasAssetsNeeded && this.getAssetVolume(index) >= N);
				for (m in spots) {
					assert m.isRunning();
					orders.add(new Order(Order.KIND_BUY_LIMIT_ORDER, this, m, m.getMarketPrice(), n, this.orderTimeLength));
					cashNeeded += m.getMarketPrice() * n;
				}
				if (cashNeeded > this.getCashAmount() || !hasAssetsNeeded) {
					orders.clear();
				}
			}
		}
		return orders;
	}
}

