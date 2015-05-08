package tekram.agent;
import x10.util.ArrayList;
import x10.util.List;
import tekram.Agent;
import tekram.Market;
import tekram.Order;

public class SingleAssetAgent extends Agent {

	public var primaryMarket:Market;
	public var orderMaking:OrderMaking;

	public def this(id:Long) {
		super(id);
		this.primaryMarket = null;
		this.orderMaking = null;
	}

	public def setPrimaryMarket(market:Market) {
		this.setMarketAccessible(market);
		this.primaryMarket = market;
	}

	public def placeOrders(market:Market):List[Order] {
		// Choose only one market and place orders.
		val orders = new ArrayList[Order]();

		//if (this.primaryMarket.isRunning()) {
			if (market == this.primaryMarket) {
				// Trade at the primary market.
				orders.addAll(this.orderMaking.decideOrders(this, this.primaryMarket));
				return orders;
			}
		//}
		return orders;
	}
}

