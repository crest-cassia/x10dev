package tekram.marketindex;
import x10.util.List;
import tekram.Market;

public class CapitalWeightedFundamentalIndex extends AverageIndex {

	public def getWeightedPrice(market:Market):Double {
		return market.getOutstandingShares() * market.getFundamentalPrice();
	}
}

