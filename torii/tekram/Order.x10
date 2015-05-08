package tekram;

public class Order {
	
	// The type-safe enum pattern.
	static struct Kind(id:String) {}
	public static KIND_BUY_MARKET_ORDER = Kind("BUY_MARKET_ORDER");
	public static KIND_SELL_MARKET_ORDER = Kind("SELL_MARKET_ORDER");
	public static KIND_BUY_LIMIT_ORDER = Kind("BUY_LIMIT_ORDER");
	public static KIND_SELL_LIMIT_ORDER = Kind("SELL_LIMIT_ORDER");
	
	public var kind:Kind;
	public var agent:Agent;
	public var market:Market;
	public var price:Double;
	public var volume:Long;
	public var timeLength:Long;
	public var timePlaced:Long;
	
	public def this(kind:Kind, agent:Agent, market:Market, price:Double, volume:Long, timeLength:Long, timePlaced:Long) {
		assert price >= 0;
		assert volume >= 0;
		this.kind = kind;
		this.agent = agent;
		this.market = market;
		this.price = price;
		this.volume = volume;
		this.timeLength = timeLength;
		this.timePlaced = timePlaced;
	}
	
	public def this(kind:Kind, agent:Agent, market:Market, price:Double, volume:Long, timeLength:Long) {
		this(kind, agent, market, price, volume, timeLength, market.getTime());
	}
	
	public def getAgent():Agent = this.agent;
	
	public def getMarket():Market = this.market;
	
	public def getPrice():Double = this.price;

	public def setPrice(price:Double) {
		this.price = price;
	}
	
	public def getVolume():Long = this.volume;
	
	public def updateVolume(delta:Long) {
		this.volume += delta;
		assert this.volume >= 0;
	}
	
	public def getTimeLength():Long = this.timeLength;
	
	public def getTimePlaced():Long = this.timePlaced;
	
	public def isBuyOrder():Boolean {
		return this.kind == Order.KIND_BUY_MARKET_ORDER || this.kind == Order.KIND_BUY_LIMIT_ORDER;
	}
	
	public def isSellOrder():Boolean {
		return this.kind == Order.KIND_SELL_MARKET_ORDER || this.kind == Order.KIND_SELL_LIMIT_ORDER;
	}
	
	public def isLimitOrder():Boolean {
		return this.kind == Order.KIND_BUY_LIMIT_ORDER || this.kind == Order.KIND_SELL_LIMIT_ORDER;
	}
	
	public def isMarketOrder():Boolean {
		return this.kind == Order.KIND_BUY_MARKET_ORDER || this.kind == Order.KIND_SELL_MARKET_ORDER;
	}
	
	public def isExpired():Boolean {
		return this.timePlaced + this.timeLength < this.market.getTime();
	}
	
	public def toString():String {
		return this.typeName() + [this.kind.id, "agent:" + (this.agent != null ? this.agent.id : this.agent), "market:" + (this.market != null ? this.market.id : this.market), this.price, this.volume, this.timeLength, this.timePlaced];
	}
}
