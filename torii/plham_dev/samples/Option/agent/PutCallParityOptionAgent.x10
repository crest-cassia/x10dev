package samples.Option.agent;
import x10.util.List;
import x10.util.ArrayList;
import plham.Market;
import plham.Order;
import plham.Agent;
import plham.util.RandomHelper;
import samples.Option.OptionAgent;
import samples.Option.OptionMatrix;

public class PutCallParityOptionAgent extends OptionAgent {

	public var underlyingId:Long;
	public var optionMatrix:OptionMatrix;

	public var getUnderlyingMarket(markets:List[Market]):Market = markets(underlyingId);

	public def getLastClosingPrice(market:OptionMarket, n:Long):Double {
		assert n >= 1;
		val u = market.getMaturityInterval();
		val du = market.getTimeToMaturity();
		assert u >= du;
		val t = market.getTime();
		val dt = (u - du) + (n - 1) * u;
		return market.getPrice(t - dt); // TODO: Check
	}

	public def getLastClosingPrice(market:OptionMarket):Double = getLastClosingPrice(market, 1);

	public def getLastPutCallParityError(underlying:Market, callOption:OptionMarket, putOption:OptionMarket):Boolean {
		// Put-call parity: P - C = K exp(-r T) - S
		val P = getLastClosingPrice(putOption);
		val C = getLastClosingPrice(callOption);
		val S = underlying.getPrice();
		val K = callOption.getStrikePrice();
		val T = callOption.getTimeToMaturity();
		val r = ???
		return Math.abs((P - C) - (K * Math.exp(-r * T) - S));
	}

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

		val s = random.nextLong(sLen);
		val u = random.nextLong(uLen);
		val callOption = markets(om.getCallMarketIdByIndex(s, u));
		val putOption = markets(om.getPutMarketIdByIndex(s, u));

		val orders = new ArrayList[Order]();

		val tol = 1e-1;
		if (getLastPutCallParityError(underlying, callOption, putOption) > tol) {
			val isCallBasis = random.nextBoolean(0.5);
			if (isCallBasis) {
				// Calculate P = f(C, S, K, r, T)
			} else {
				// Calculate C = f(P, S, K, r, T)
			}
		}

//		var orderPrice:Double = ...
//		var orderVolume:Long = 1;
//
//		val volatilityThreshold = getRecentAverageVolatility(underlying);
//		val historicalVolatility = computeHistoricalVolatility(underlying);
//
//		if (historicalVolatility > volatilityThreshold) {
//			orders.add(new Order(Order.KIND_LIMIT_BUY_ORDER, callOption, this, ...));
//			orders.add(new Order(Order.KIND_LIMIT_BUY_ORDER, putOption, this, ...));
//		} else {
//			orders.add(new Order(Order.KIND_LIMIT_SELL_ORDER, callOption, this, ...));
//			orders.add(new Order(Order.KIND_LIMIT_SELL_ORDER, putOption, this, ...));
//		}
		return orders;
	}
}
