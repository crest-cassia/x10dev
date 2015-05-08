package tekram.marketindex;
import x10.util.List;
import tekram.Market;

public abstract class MarketIndex {

	public abstract def getIndex(markets:List[Market]):Double;

	public abstract def getWeightedPrice(market:Market):Double;
}
