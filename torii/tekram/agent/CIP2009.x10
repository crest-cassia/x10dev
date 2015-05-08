package tekram.agent;
import x10.util.ArrayList;
import x10.util.List;
import x10.util.Random;
import tekram.Agent;
import tekram.Global;
import tekram.Market;
import tekram.Order;
import tekram.util.Brent;
import tekram.util.Gaussian;
import tekram.util.Statistics;
import tekram.util.MovingStatistics;

/**
 * An order decision mechanism proposed in Chiarella, Iori, Perello (2009).
 * It employs absolute constant risk aversion (CARA) and is restricted to make
 * no debt and no short selling.
 */
public class CIP2009 implements OrderMaking {

	public static TIME_WINDOW_SIZE_SCALE = 100.0;
	public static UTILITY_EXPONENT_SCALE = 0.1;
	public static NOISE_SIGMA = 0.0001;
	public static FUNDAMENTAL_MEAN_REVERSION_TIME = TIME_WINDOW_SIZE_SCALE; // NOTE: The value cannot be found in CIP(2009).

	public var fundamentalWeight:Double;
	public var chartWeight:Double;
	public var noiseWeight:Double;
	public var isChartFollowing:Boolean;
	public var styleCoefficient:Double;
	public var timeWindowSizeScale:Double;
	public var riskAversionScale:Double;
	public var fundamentalMeanReversionTime:Double; // A common knowledge?
	public var noiseScale:Double;
	public var timeWindowSizeMin:Long;

	public var STATISTICS:MovingStatistics;

	public def this(fundamentalWeight:Double, chartWeight:Double, noiseWeight:Double) {
		this.fundamentalWeight = fundamentalWeight;
		this.chartWeight = chartWeight;
		this.noiseWeight = noiseWeight;
		this.isChartFollowing = true; // A trend-follower or contrarian.
		this.styleCoefficient = (1.0 + fundamentalWeight) / (1.0 + chartWeight);
		this.timeWindowSizeScale = TIME_WINDOW_SIZE_SCALE;
		this.riskAversionScale = UTILITY_EXPONENT_SCALE;
		this.fundamentalMeanReversionTime = FUNDAMENTAL_MEAN_REVERSION_TIME;
		this.noiseScale = NOISE_SIGMA;
		this.timeWindowSizeMin = 50;
		assert fundamentalWeight >= 0.0 : "fundamentalWeight >= 0.0";
		assert chartWeight >= 0.0 : "chartWeight >= 0.0";
		assert noiseWeight >= 0.0 : "noiseWeight >= 0.0";
		this.STATISTICS = new MovingStatistics();
	}

	public static def isFinite(x:Double) {
		return !x.isNaN() && !x.isInfinite();
	}

	public def decideOrders(agent:Agent, market:Market):List[Order] {
//		assert agent.isMarketAccessible(market) && market.isRunning(); // It does NOT check this.
		// Place only one order.
		val orders = new ArrayList[Order]();

//		if (agent.getCashAmount() <= 0.0 || agent.getAssetVolume(market) <= 0) {
//			return orders; // Stop thinking.
//		}

		val random = new Random();
		val gaussian = new Gaussian(random);

		val t = market.getTime();
		val timeWindowSizeMax = this.timeWindowSizeMin + Math.ceil(this.timeWindowSizeScale * this.styleCoefficient) as Long;
		val timeWindowSize = Math.min(t, timeWindowSizeMax);
		val riskAversionConstant = this.riskAversionScale * this.styleCoefficient;
		assert timeWindowSize > 0 : "timeWindowSize > 0";
		assert riskAversionConstant > 0.0 : "riskAversionConstant > 0.0";

		if (!this.STATISTICS.exists(market.marketReturns, timeWindowSizeMax)) {
			this.STATISTICS.register(market.marketReturns, timeWindowSizeMax, (x:Double)=>Math.log(x));
		} else {
			this.STATISTICS.update(); // TODO: Avoid multiple updates
		}
		
		val fundamentalLogReturn = Math.log(market.getFundamentalPrice(t) / market.getMarketPrice(t));
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

		val chartVarianceLogReturn = this.STATISTICS.variance(market.marketReturns, timeWindowSizeMax);
		if (chartVarianceLogReturn <= 1e-32) {
			return orders; // Stop thinking.
		}

		if (false) {
			var loopSumLogReturn:Double = 0.0;
			for (j in 0..(timeWindowSize - 1)) {
				loopSumLogReturn += Math.log(market.getMarketReturn(t - j));
			}
			val loopMeanLogReturn = loopSumLogReturn / timeWindowSize;
			var loopSSELogReturn:Double = 0.0;
			for (j in 0..(timeWindowSize - 1)) {
				loopSSELogReturn += Math.pow((Math.log(market.getMarketReturn(t - j)) - loopMeanLogReturn), 2.0);
			}
			val loopVarianceLogReturn = loopSSELogReturn / timeWindowSize;
			val subReturns = market.marketReturns.subList(Math.max(t - timeWindowSize + 1, 0), t + 1);
			val subLogReturns = Statistics.log(subReturns);
			Console.OUT.println([subLogReturns.size(), timeWindowSizeMax]);
			Console.OUT.println([
				loopMeanLogReturn, Statistics.mean(subLogReturns),
				this.STATISTICS.mean(market.marketReturns, timeWindowSizeMax)]);
			Console.OUT.println([
				loopVarianceLogReturn, Statistics.variance(subLogReturns),
				this.STATISTICS.variance(market.marketReturns, timeWindowSizeMax)]);
			assert Math.abs(loopMeanLogReturn - Statistics.mean(subLogReturns)) < 1e-6;
			assert Math.abs(loopVarianceLogReturn - Statistics.variance(subLogReturns)) < 1e-6;
			assert Math.abs(loopMeanLogReturn -  this.STATISTICS.mean(market.marketReturns, timeWindowSizeMax)) < 1e-6;
			assert Math.abs(loopVarianceLogReturn -  this.STATISTICS.variance(market.marketReturns, timeWindowSizeMax)) < 1e-6;
		}

		if (Global.DEBUG > 0) {
			Console.OUT.println("expectedLogReturn " + expectedLogReturn);
			Console.OUT.println("expectedFuturePrice " + expectedFuturePrice);
			Console.OUT.println("this.fundamentalWeight " + this.fundamentalWeight);
			Console.OUT.println("this.chartWeight " + this.chartWeight);
			Console.OUT.println("this.noiseWeight " + this.noiseWeight);
			Console.OUT.println("fundamentalLogReturn " + fundamentalLogReturn);
			Console.OUT.println("(fundamentalScale * fundamentalLogReturn) " + (fundamentalScale * fundamentalLogReturn));
			Console.OUT.println("chartMeanLogReturn " + chartMeanLogReturn);
			Console.OUT.println("noiseLogReturn " + noiseLogReturn);
			Console.OUT.println("assetsVolumes(market) " + agent.getAssetVolume(market));
			Console.OUT.println("cashAmount " + agent.getCashAmount());
			Console.OUT.println("riskAversionConstant " + riskAversionConstant);
			Console.OUT.println("expectedFuturePrice " + expectedFuturePrice);
			Console.OUT.println("chartVarianceLogReturn " + chartVarianceLogReturn);
		}

		val pi = (x:Double) => Math.log(expectedFuturePrice / x) / (riskAversionConstant * chartVarianceLogReturn * x);
		val fs = (x:Double) => Math.log(expectedFuturePrice) - Math.log(x) - riskAversionConstant * chartVarianceLogReturn * agent.getAssetVolume(market) * x;
		val fm = (x:Double) => Math.log(expectedFuturePrice) - Math.log(x) - riskAversionConstant * chartVarianceLogReturn * (agent.getAssetVolume(market) * x + agent.getCashAmount());

		var priceMaximal:Double;
		var priceOptimal:Double;
		var priceMinimal:Double;
		try {
			priceMaximal = expectedFuturePrice;
			priceOptimal = Brent.optimize(fs, 1e-32, priceMaximal);
			priceMinimal = Brent.optimize(fm, 1e-32, priceMaximal);
		} catch (e:Exception) {
			return orders; // Stop thinking.
		}
		if (Global.DEBUG > 0) {
			Console.OUT.println("priceMaximal " + priceMaximal + ", pi() " + pi(priceMaximal));
			Console.OUT.println("priceOptimal " + priceOptimal + ", pi() " + pi(priceOptimal) + ", " + fs(priceOptimal));
			Console.OUT.println("priceMinimal " + priceMinimal + ", pi() " + pi(priceMinimal) + ", " + fm(priceMinimal));
		}
		if (pi(priceMaximal).isNaN() || pi(priceOptimal).isNaN() || pi(priceMinimal).isNaN()) {
			return orders; // Stop thinking.
		}
		assert Math.round(priceMinimal * 1000) <= Math.round(priceOptimal * 1000);
		assert Math.round(priceOptimal * 1000) <= Math.round(priceMaximal * 1000);

		val highestBuyPrice = market.getBuyOrderBook().getBestPrice();
		val lowestSellPrice = market.getSellOrderBook().getBestPrice();
		var orderPrice:Double = random.nextDouble() * (priceMaximal - priceMinimal) + priceMinimal;
		var orderVolume:Long = 0;
		assert priceMinimal <= orderPrice;
		assert orderPrice <= priceMaximal;

		if (orderPrice < priceOptimal) {
			if (orderPrice >= lowestSellPrice && lowestSellPrice > priceMinimal) {
				orderPrice = lowestSellPrice;
				//Console.OUT.println("BUY_MARKET_ORDER-like");
			}
			orderVolume = (pi(orderPrice) - agent.getAssetVolume(market)) as Long;
			if (orderVolume > 0) {
				orders.add(new Order(Order.KIND_BUY_LIMIT_ORDER, agent, market, orderPrice, orderVolume, timeWindowSize));
				//Console.OUT.println("Submitted a buy order");
			}
			assert orderPrice >= 0.0 : ["orderPrice >= 0.0", orderPrice];
			assert orderVolume >= 0 : ["orderVolume >= 0", orderVolume];
			assert agent.getCashAmount() >= orderPrice * orderVolume : ["agent.getCashAmount() >= orderPrice * orderVolume", agent.getCashAmount(), orderPrice * orderVolume];
		}
		if (orderPrice > priceOptimal) {
			if (orderPrice <= highestBuyPrice && highestBuyPrice < priceMaximal) {
				orderPrice = highestBuyPrice;
				//Console.OUT.println("SELL_MARKET_ORDER-like");
			}
			orderVolume = (agent.getAssetVolume(market) - pi(orderPrice)) as Long;
			if (orderVolume > 0) {
				orders.add(new Order(Order.KIND_SELL_LIMIT_ORDER, agent, market, orderPrice, orderVolume, timeWindowSize));
				//Console.OUT.println("Submitted a sell order");
			}
			assert orderPrice >= 0.0 : ["orderPrice >= 0.0", orderPrice];
			assert orderVolume >= 0 : ["orderVolume >= 0", orderVolume];
			assert agent.getAssetVolume(market) >= orderVolume : ["agent.getAssetVolume(market) >= orderVolume", agent.getAssetVolume(market), orderVolume];
		}

		if (Global.DEBUG > 0) {
			Console.OUT.println("highestBuyPrice " + highestBuyPrice);
			Console.OUT.println("lowestSellPrice " + lowestSellPrice);
			Console.OUT.println("orderPrice " + orderPrice);
			Console.OUT.println("orderVolume " + orderVolume);
		}
		return orders;
	}

	public static def main(args:Rail[String]) {
//		val riskAversionConstant = 0.207881421039;
//		val expectedFuturePrice = 283.605078562;
//		val varianceLogReturn = 3.84808016118e-07;
//		val assetVolume = 18;
//		val cashAmount = 5191.96178162;
//		val riskAversionConstant = 0.169516948841;
//		val expectedFuturePrice = 299.346192766;
//		val varianceLogReturn = 9.16468822313e-07;
//		val assetVolume = 20;
//		val cashAmount = 603.311911064;
		val riskAversionConstant = 0.488072464385;
		val expectedFuturePrice = 301.275408155;
		val varianceLogReturn = 1.71442629065e-06;
		val assetVolume = 24;
		val cashAmount = 14398.4012076;
		val pi = (x:Double) => Math.log(expectedFuturePrice / x) / (riskAversionConstant * varianceLogReturn * x);
		val fs = (x:Double) => Math.log(expectedFuturePrice) - Math.log(x) - riskAversionConstant * varianceLogReturn * assetVolume * x;
		val fm = (x:Double) => Math.log(expectedFuturePrice) - Math.log(x) - riskAversionConstant * varianceLogReturn * (assetVolume * x + cashAmount);
		
		Console.OUT.println("Optimize priceMaximal " + expectedFuturePrice);
		val priceMaximal = expectedFuturePrice;
		Console.OUT.println("Optimize priceOptimal");
		val priceOptimal = Brent.optimize(fs, 1e-6, priceMaximal);
		Console.OUT.println("Optimize priceMinimal");
		val priceMinimal = Brent.optimize(fm, 1e-6, priceMaximal);
		Console.OUT.println("priceMaximal " + priceMaximal + ", pi() " + pi(priceMaximal));
		Console.OUT.println("priceOptimal " + priceOptimal + ", pi() " + pi(priceOptimal) + ", " + fs(priceOptimal));
		Console.OUT.println("priceMinimal " + priceMinimal + ", pi() " + pi(priceMinimal) + ", " + fm(priceMinimal));
	}
}

