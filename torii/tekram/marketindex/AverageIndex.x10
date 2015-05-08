package tekram.marketindex;
import x10.util.List;
import tekram.Market;

public abstract class AverageIndex extends MarketIndex {

	public var normal:Double;
	public var scale:Double;

	public def this() {
		this(1.0, 1.0);
	}

	public def this(normal:Double, scale:Double) {
		this.normal = normal;
		this.scale = scale;
	}

	public def getIndex(markets:List[Market]):Double {
		var sum:Double = 0.0;
		for (market in markets) {
			sum += this.getWeightedPrice(market);
		}
		val meanPrice = sum / markets.size();
		return (meanPrice / this.normal) * this.scale;
	}

	public abstract def getWeightedPrice(market:Market):Double;
}
