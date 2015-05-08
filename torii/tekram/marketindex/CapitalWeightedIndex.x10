package tekram.marketindex;
import x10.util.List;
import tekram.Market;

public class CapitalWeightedIndex extends AverageIndex {

	public def getWeightedPrice(market:Market):Double {
		return market.getOutstandingShares() * market.getMarketPrice();
	}
}
