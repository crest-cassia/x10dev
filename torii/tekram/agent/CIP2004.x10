package tekram.agent;
import x10.util.ArrayList;
import x10.util.List;
import x10.util.Random;
import tekram.Agent;
import tekram.Global;
import tekram.Market;
import tekram.Order;
import tekram.util.Gaussian;
import tekram.util.MovingStatistics;

/**
 * An order decision mechanism proposed in Chiarella, Iori (2004).
 * It employs a simple margin-based random trading.
 * Extensions:
 *   * Delay on fundamental price information.
 */
public class CIP2004 implements OrderMaking {

	public static TIME_WINDOW_SIZE_SCALE = 100.0;
	public static NOISE_SIGMA = 0.001;
	public static FUNDAMENTAL_MEAN_REVERSION_TIME = TIME_WINDOW_SIZE_SCALE; // NOTE: The value cannot be found in CIP(2009).

	public var fundamentalWeight:Double;
	public var chartWeight:Double;
	public var noiseWeight:Double;
	public var isChartFollowing:Boolean;
	public var marginWidth:Double;
	public var styleCoefficient:Double;
	public var timeWindowSizeScale:Double;
	public var fundamentalMeanReversionTime:Double; // A common knowledge?
	public var noiseScale:Double;
	public var timeWindowSizeMin:Long;
	public var informationDelay:Long;

	public var STATISTICS:MovingStatistics;

	public def this(fundamentalWeight:Double, chartWeight:Double, noiseWeight:Double) {
		this.fundamentalWeight = fundamentalWeight;
		this.chartWeight = chartWeight;
		this.noiseWeight = noiseWeight;
		this.isChartFollowing = true; // A trend-follower or contrarian.
		this.marginWidth = 0.5;
		this.styleCoefficient = (1.0 + fundamentalWeight) / (1.0 + chartWeight);
		this.timeWindowSizeScale = TIME_WINDOW_SIZE_SCALE;
		this.fundamentalMeanReversionTime = FUNDAMENTAL_MEAN_REVERSION_TIME;
		this.noiseScale = NOISE_SIGMA;
		assert fundamentalWeight >= 0.0 : "fundamentalWeight >= 0.0";
		assert chartWeight >= 0.0 : "chartWeight >= 0.0";
		assert noiseWeight >= 0.0 : "noiseWeight >= 0.0";
		this.timeWindowSizeMin = 50;
		this.informationDelay = 0;
		this.STATISTICS = new MovingStatistics();
	}

	public static def isFinite(x:Double) {
		return !x.isNaN() && !x.isInfinite();
	}

	public def decideOrders(agent:Agent, market:Market):List[Order] {
//		assert agent.isMarketAccessible(market) && market.isRunning(); // It does NOT check this.
		// Place only one order.
		val orders = new ArrayList[Order]();

		val random = new Random();
		val gaussian = new Gaussian(random);

		val t = market.getTime();
		val timeWindowSizeMax = this.timeWindowSizeMin + Math.ceil(this.timeWindowSizeScale * this.styleCoefficient) as Long;
		val timeWindowSize = Math.min(t, timeWindowSizeMax);
		val marginWidth = this.marginWidth;
		val informationDelay = this.informationDelay;
		assert timeWindowSize > 0 : "timeWindowSize > 0";
		assert 0.0 <= marginWidth && marginWidth <= 1.0;
		assert informationDelay >= 0;

		if (!this.STATISTICS.exists(market.marketReturns, timeWindowSizeMax)) {
			this.STATISTICS.register(market.marketReturns, timeWindowSizeMax, (x:Double)=>Math.log(x));
		} else {
			this.STATISTICS.update(); // TODO: Avoid multiple updates
		}
		
		val td = Math.max(0, t - informationDelay);
		val fundamentalLogReturn = Math.log(market.getFundamentalPrice(td) / market.getMarketPrice(t));
		assert isFinite(fundamentalLogReturn) : "isFinite(fundamentalLogReturn)";

		val chartMeanLogReturn = this.STATISTICS.mean(market.marketReturns, timeWindowSizeMax);
		assert isFinite(chartMeanLogReturn) : "isFinite(chartMeanLogReturn)";

		val noiseLogReturn = 0.0 + this.noiseScale * gaussian.nextGaussian();
		assert isFinite(noiseLogReturn) : "isFinite(noiseLogReturn)";
		
		val fundamentalScale = 1.0 / this.fundamentalMeanReversionTime;
		val chartStyle = (this.isChartFollowing ? +1.0 : -1.0);
		val expectedLogReturn = (1.0 / (this.fundamentalWeight + this.chartWeight + this.noiseWeight))
				* (this.fundamentalWeight * fundamentalScale * fundamentalLogReturn
					+ this.chartWeight * chartStyle * chartMeanLogReturn
					+ this.noiseWeight * noiseLogReturn);
		assert isFinite(expectedLogReturn) : "isFinite(expectedLogReturn)";
		
		val expectedFuturePrice = market.getMarketPrice(t) * Math.exp(expectedLogReturn * timeWindowSize);
		assert isFinite(expectedFuturePrice) : "isFinite(expectedFuturePrice)";

		val highestBuyPrice = market.getBuyOrderBook().getBestPrice();
		val lowestSellPrice = market.getSellOrderBook().getBestPrice();
		var orderPrice:Double = 0.0;
		var orderVolume:Long = 0;

		if (expectedFuturePrice > market.getMarketPrice(t)) {
			orderPrice = expectedFuturePrice * (1 - marginWidth);
			if (orderPrice >= lowestSellPrice && lowestSellPrice > 0.0) {
				orderPrice = lowestSellPrice;
				//Console.OUT.println("BUY_MARKET_ORDER-like");
			}
			orderVolume = 1;
			if (orderVolume > 0) {
				orders.add(new Order(Order.KIND_BUY_LIMIT_ORDER, agent, market, orderPrice, orderVolume, timeWindowSize));
				//Console.OUT.println("Submitted a buy order");
			}
			assert orderPrice >= 0.0 : ["orderPrice >= 0.0", orderPrice];
			assert orderVolume >= 0 : ["orderVolume >= 0", orderVolume];
		}
		if (expectedFuturePrice < market.getMarketPrice(t)) {
			orderPrice = expectedFuturePrice * (1 + marginWidth);
			if (0.0 < orderPrice && orderPrice <= highestBuyPrice) {
				orderPrice = highestBuyPrice;
				//Console.OUT.println("SELL_MARKET_ORDER-like");
			}
			orderVolume = 1;
			if (orderVolume > 0) {
				orders.add(new Order(Order.KIND_SELL_LIMIT_ORDER, agent, market, orderPrice, orderVolume, timeWindowSize));
				//Console.OUT.println("Submitted a sell order");
			}
			assert orderPrice >= 0.0 : ["orderPrice >= 0.0", orderPrice];
			assert orderVolume >= 0 : ["orderVolume >= 0", orderVolume];
		}

		if (Global.DEBUG > 0) {
			Console.OUT.println("highestBuyPrice " + highestBuyPrice);
			Console.OUT.println("lowestSellPrice " + lowestSellPrice);
			Console.OUT.println("orderPrice " + orderPrice);
			Console.OUT.println("orderVolume " + orderVolume);
		}
		return orders;
	}
}

