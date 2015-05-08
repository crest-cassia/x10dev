package tekram.agent;
import x10.util.ArrayList;
import x10.util.HashMap;
import x10.util.HashSet;
import x10.util.List;
import x10.util.Map;
import x10.util.Random;
import x10.util.Set;
import tekram.Agent;
import tekram.Market;
import tekram.Order;

public class AlterSingleAssetAgent extends SingleAssetAgent {

	public var secondaryMarket:Market; // Not in use if it == null.
	public var secondaryMarketsAllowed:Set[Market];

	public def this(id:Long) {
		super(id);
		this.secondaryMarket = null;
		this.secondaryMarketsAllowed = new HashSet[Market]();
	}

	public def setSecondaryMarketAccessible(market:Market) {
		this.setMarketAccessible(market);
		this.secondaryMarketsAllowed.add(market);
	}

	public def isUsingSecondary():Boolean {
		return this.secondaryMarket != null;
	}

	public def placeOrders(market:Market):List[Order] {
		assert this.orderMaking instanceof AlterOrderMaking;
		// Choose only one market and place orders.
		val random = new Random();
		val orders = new ArrayList[Order]();

		if (this.primaryMarket.isRunning()) {
			if (this.isUsingSecondary()) {
				assert this.secondaryMarket.isRunning();
				if (market == this.secondaryMarket) {
					// Trading halt has been released.
					// To unwind, place orders.
					val timeLength = 10; // TODO: Executed ASAP.
					if (this.getAssetVolume(this.secondaryMarket) > 0) {
						orders.add(new Order(Order.KIND_SELL_LIMIT_ORDER, this, this.secondaryMarket,
							this.secondaryMarket.getMarketPrice(),
							this.getAssetVolume(this.secondaryMarket), timeLength));
					}
					if (this.getAssetVolume(this.secondaryMarket) < 0) {
						orders.add(new Order(Order.KIND_BUY_LIMIT_ORDER, this, this.secondaryMarket,
							this.secondaryMarket.getMarketPrice(),
							this.getAssetVolume(this.secondaryMarket), timeLength));
					}
					this.secondaryMarket = null;
					return orders;
				}
			}
			if (market == this.primaryMarket) {
				// Trade at the primary market.
				orders.addAll(this.orderMaking.decideOrders(this, this.primaryMarket));
				return orders;
			}
		} else {
			if (!this.isUsingSecondary()) {
				this.secondaryMarket = (this.orderMaking as AlterOrderMaking).chooseAlternativeMarket(this.primaryMarket, this.secondaryMarketsAllowed);
				if (this.secondaryMarket == null) {
					return orders;
				}
			}
			if (market == this.secondaryMarket) {
				assert this.secondaryMarket.isRunning();
				// Trade at the secondary market.
				orders.addAll((this.orderMaking as AlterOrderMaking).decideOrders(this, this.primaryMarket, this.secondaryMarket));
				return orders;
			}
		}
		return orders;
	}
}

