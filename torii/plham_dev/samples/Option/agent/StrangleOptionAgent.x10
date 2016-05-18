package samples.Option.agent;
import x10.util.List;
import x10.util.ArrayList;
import plham.Market;
import plham.Order;
import plham.Agent;
import plham.util.RandomHelper;
import samples.Option.OptionAgent;
import samples.Option.OptionMatrix;

public class StrangleOptionAgent extends OptionAgent {

	public var underlyingId:Long;
	public var optionMatrix:OptionMatrix;

	public var getUnderlyingMarket(markets:List[Market]):Market = markets(underlyingId);

	public def submitOrders(markets:List[Market]):List[Order] {
		val random = new RandomHelper(getRandom());

		val underlying = getUnderlyingMarket(markets);

		if (optionMatrix == null) {
			optionMatrix = new OptionMatrix(underlying.id);
			optionMatrix.setup(markets);
		}
		val om = optionMatrix;

		val sLen = om.numStrikePrices(); // max + 1
		val uLen = om.numMaturityTimes(); // max + 1

		val sATM = om.toStrikePriceIndex(underlying.getPrice()); // Find strikePrice == underlyingPrice.

		// TODO: Currently ATM inclusive, so there always is one OptionMarket.
		val sCall = sATM + random.nextLong(sLen - sATM); // OTM(Call) if strikePrice > underlyingPrice
		val sPut = random.nextLong(sATM + 1); // OTM(Put) if strikePrice < underlyingPrice
		val u = random.nextLong(uLen);
		val callOption = markets(om.getCallMarketIdByIndex(sCall, u));
		val putOption = markets(om.getPutMarketIdByIndex(sPut, u));

		val orders = new ArrayList[Order]();

		var orderPrice:Double = ...
		var orderVolume:Long = 1;

		val volatilityThreshold = getRecentAverageVolatility(underlying);
		val historicalVolatility = computeHistoricalVolatility(underlying);

		if (historicalVolatility > volatilityThreshold) {
			orders.add(new Order(Order.KIND_LIMIT_BUY_ORDER, callOption, this, ...));
			orders.add(new Order(Order.KIND_LIMIT_BUY_ORDER, putOption, this, ...));
		} else {
			orders.add(new Order(Order.KIND_LIMIT_SELL_ORDER, callOption, this, ...));
			orders.add(new Order(Order.KIND_LIMIT_SELL_ORDER, putOption, this, ...));
		}
		return orders;
	}
}
