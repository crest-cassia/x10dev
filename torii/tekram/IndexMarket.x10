package tekram;
import x10.util.ArrayList;
import x10.util.List;
import tekram.marketindex.MarketIndex;

public class IndexMarket extends Market {

	public var markets:List[Market];
	public var marketIndexMethod:MarketIndex;
	public var fundamentalIndexMethod:MarketIndex;

	public def this(id:Long) {
		super(id);
		this.markets = new ArrayList[Market]();
	}

	public def addMarket(market:Market) {
		assert !this.markets.contains(market);
		this.markets.add(market);
	}

	public def getMarkets() = this.markets;

	public def setMarketIndexMethod(method:MarketIndex) {
		this.marketIndexMethod = method;
	}

	public def setFundamentalIndexMethod(method:MarketIndex) {
		this.fundamentalIndexMethod = method;
	}

	public def getMarketIndex():Double {
		return this.marketIndexMethod.getIndex(this.markets);
	}

	public def getFundamentalIndex():Double {
		return this.fundamentalIndexMethod.getIndex(this.markets);
	}

	public def getWeightedMarketPrice(market:Market):Double {
		return this.marketIndexMethod.getWeightedPrice(market);
	}
}
