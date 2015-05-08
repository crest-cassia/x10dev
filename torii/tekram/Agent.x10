package tekram;
import x10.util.ArrayList;
import x10.util.HashMap;
import x10.util.List;
import x10.util.Map;
import x10.util.Random;

public class Agent(id:Long) {
	
	public var cashAmount:Double;
	public var assetsVolumes:Map[Market,Long];
	
	public def this(id:Long) {
		property(id);
		this.cashAmount = 0.0;
		this.assetsVolumes = new HashMap[Market,Long]();
	}

	public def placeOrders(markets:List[Market]):List[Order] {
		/* This implementation is to be a test-friendly base class. */
		val orders = new ArrayList[Order]();
		for (market in markets) {
			orders.addAll(this.placeOrders(market));
		}
		return orders;
	}
	
	public def placeOrders(market:Market):List[Order] {
		/* This implementation is to be a test-friendly base class. */
		val MARGIN_SCALE = 10.0;
		val VOLUME_SCALE = 100;
		val TIME_LENGTH_SCALE = 100;
		val BUY_CHANCE = 0.4;
		val SELL_CHANCE = 0.4;

		val orders = new ArrayList[Order]();
		
		if (this.isMarketAccessible(market)) {
			val random = new Random();
			val price = market.getMarketPrice() + (random.nextDouble() * 2 * MARGIN_SCALE - MARGIN_SCALE);
			val volume = random.nextLong(VOLUME_SCALE) + 1;
			val timeLength = random.nextLong(TIME_LENGTH_SCALE) + 10;
			val p = random.nextDouble();
			if (p < BUY_CHANCE) {
				orders.add(new Order(Order.KIND_BUY_LIMIT_ORDER, this, market, price, volume, timeLength));
			} else if (p < BUY_CHANCE + SELL_CHANCE) {
				orders.add(new Order(Order.KIND_SELL_LIMIT_ORDER, this, market, price, volume, timeLength));
			}
		}
		return orders;
	}
	
	public def isMarketAccessible(market:Market):Boolean {
		return this.assetsVolumes.containsKey(market);
	}
	
	public def setMarketAccessible(market:Market) {
		this.assetsVolumes.put(market, 0);
	}

	public def getCashAmount():Double {
		return this.cashAmount;
	}
	
	public def setCashAmount(cashAmount:Double) {
		this.cashAmount = cashAmount;
	}
	
	public def updateCashAmount(delta:Double) {
		this.cashAmount += delta;
	}

	public def getAssetVolume(market:Market):Long {
		assert this.isMarketAccessible(market);
		return this.assetsVolumes.get(market);
	}
	
	public def setAssetVolume(market:Market, assetVolume:Long) {
		assert this.isMarketAccessible(market);
		this.assetsVolumes.put(market, assetVolume);
	}
	
	public def updateAssetVolume(market:Market, delta:Long) {
		assert this.isMarketAccessible(market);
		this.assetsVolumes.put(market, this.assetsVolumes.get(market) + delta);
	}
	
	public def toString():String {
		return this.typeName() + [this.id, this.cashAmount, this.assetsVolumes.keySet()];
	}
}
