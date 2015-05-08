package tekram.marketindex;
import x10.util.List;
import tekram.Market;

public class PriceWeightedFundamentalIndex extends AverageIndex {

	public def getWeightedPrice(market:Market):Double {
		return market.getFundamentalPrice();
	}
}

