package tekram.agent;
import x10.util.ArrayList;
import x10.util.List;
import x10.util.Random;
import x10.util.Set;
import tekram.Agent;
import tekram.Global;
import tekram.Market;
import tekram.Order;
import tekram.util.Brent;
import tekram.util.Gaussian;
import tekram.util.Statistics;

/**
 * An order decision mechanism proposed in Chiarella, Iori, Perello (2009)
 * with an extension for alternative-asset trading based on regression.
 * It employs absolute constant risk aversion (CARA) and is restricted to make
 * no debt and no short selling.
 */
public class CIP2004RegressionAlternative extends CIP2004 implements AlterOrderMaking {

	public def this(fundamentalWeight:Double, chartWeight:Double, noiseWeight:Double) {
		super(fundamentalWeight, chartWeight, noiseWeight);
	}

	public def decideOrders(agent:Agent, primary:Market, secondary:Market):List[Order] {
//		assert agent.isMarketAccessible(market) && market.isRunning(); // It does NOT check this.
		assert agent.isMarketAccessible(primary);
		assert agent.isMarketAccessible(secondary);
		// Place only one order.
		val orders = new ArrayList[Order]();

		val t = Global.TIME.get();
		val primary$price = primary.getMarketPrice(t);
		val secondary$price = secondary.getMarketPrice(t);
		val secondary$tempAssetVolume = agent.getAssetVolume(secondary); // + (primary$price / secondary$price) * agent.getAssetVolume(primary);

		val random = new Random();
		val gaussian = new Gaussian(random);

		val styleCoefficient = (1.0 + fundamentalWeight) / (1.0 + chartWeight);
		val timeWindowSizeMax = this.timeWindowSizeMin + Math.ceil(this.timeWindowSizeScale * styleCoefficient) as Long;
		val timeWindowSize = Math.min(t, timeWindowSizeMax);
		val marginWidth = this.marginWidth;
		val chartStyle = (this.isChartFollowing ? +1.0 : -1.0);
		assert timeWindowSize > 0 : "timeWindowSize > 0";
		assert 0.0 <= marginWidth && marginWidth <= 1.0;

		if (!Global.STATISTICS.exists(primary.marketReturns, timeWindowSizeMax)) {
			Global.STATISTICS.register(primary.marketReturns, timeWindowSizeMax, (x:Double)=>Math.log(x));
		}
		if (!Global.STATISTICS.exists(secondary.marketReturns, timeWindowSizeMax)) {
			Global.STATISTICS.register(secondary.marketReturns, timeWindowSizeMax, (x:Double)=>Math.log(x));
		}
		if (!Global.STATISTICS.exists(primary.marketReturns, secondary.marketReturns, timeWindowSizeMax)) {
			Global.STATISTICS.register(primary.marketReturns, secondary.marketReturns, timeWindowSizeMax, (x:Double)=>Math.log(x));
		}
		
		val primary$fundamentalLogReturn = Math.log(primary.getFundamentalPrice(t) / primary.getMarketPrice(t));
		assert isFinite(primary$fundamentalLogReturn) : "isFinite(primary$fundamentalLogReturn)";

		val primary$chartMeanLogReturn = Global.STATISTICS.mean(primary.marketReturns, timeWindowSizeMax);
		assert isFinite(primary$chartMeanLogReturn) : "isFinite(primary$chartMeanLogReturn)";
		
		val primary$noiseLogReturn = 0.0 + this.noiseScale * gaussian.nextGaussian();
		assert isFinite(primary$noiseLogReturn) : "isFinite(primary$noiseLogReturn)";
		
		val primary$fundamentalScale = 1.0 / this.fundamentalMeanReversionTime;
		val primary$expectedLogReturn = (1.0 / (this.fundamentalWeight + this.chartWeight + this.noiseWeight))
				* (this.fundamentalWeight * primary$fundamentalScale * primary$fundamentalLogReturn
					+ this.chartWeight * chartStyle * primary$chartMeanLogReturn
					+ this.noiseWeight * primary$noiseLogReturn);
		assert isFinite(primary$expectedLogReturn) : "isFinite(primary$expectedLogReturn)";
		
		val primary$expectedFuturePrice = primary.getMarketPrice(t) * Math.exp(primary$expectedLogReturn * timeWindowSize);
		assert isFinite(primary$expectedFuturePrice) : "isFinite(primary$expectedFuturePrice)";

		val primary$chartVarianceLogReturn = Global.STATISTICS.variance(primary.marketReturns, timeWindowSizeMax);
		if (primary$chartVarianceLogReturn <= 1e-32) {
			return orders; // Stop thinking.
		}
		//////////////////////////////
		val secondary$chartMeanLogReturn = Global.STATISTICS.mean(secondary.marketReturns, timeWindowSizeMax);
		assert isFinite(secondary$chartMeanLogReturn) : "isFinite(secondary$chartMeanLogReturn)";

		val secondary$chartVarianceLogReturn = Global.STATISTICS.variance(secondary.marketReturns, timeWindowSizeMax);
		if (secondary$chartVarianceLogReturn <= 1e-32) {
			return orders; // Stop thinking.
		}

		val joint$chartVarianceLogReturn = Global.STATISTICS.covariance(primary.marketReturns, secondary.marketReturns, timeWindowSizeMax);
		if (joint$chartVarianceLogReturn <= 1e-32) {
			return orders; // Stop thinking.
		}

		val slope = joint$chartVarianceLogReturn / primary$chartVarianceLogReturn;
		val secondary$expectedLogReturn = slope * (primary$expectedLogReturn - primary$chartMeanLogReturn) + secondary$chartMeanLogReturn;
//		val regression = Global.STATISTICS.regression(primary.marketReturns, secondary.marketReturns, timeWindowSizeMax);
//		val secondary$expectedLogReturn = regression(primary$expectedLogReturn);
		val secondary$expectedFuturePrice = secondary.getMarketPrice(t) * Math.exp(secondary$expectedLogReturn * timeWindowSize);
		//////////////////////////////

		val highestBuyPrice = secondary.getBuyOrderBook().getBestPrice();
		val lowestSellPrice = secondary.getSellOrderBook().getBestPrice();
		var orderPrice:Double = 0.0;
		var orderVolume:Long = 0;

		if (secondary$expectedFuturePrice > secondary.getMarketPrice(t)) {
			orderPrice = secondary$expectedFuturePrice * (1 - marginWidth);
			if (orderPrice >= lowestSellPrice && lowestSellPrice > 0.0) {
				orderPrice = lowestSellPrice;
				//Console.OUT.println("BUY_MARKET_ORDER-like");
			}
			orderVolume = 1;
			if (orderVolume > 0) {
				orders.add(new Order(Order.KIND_BUY_LIMIT_ORDER, agent, secondary, orderPrice, orderVolume, timeWindowSize));
				//Console.OUT.println("Submitted a buy order");
			}
			assert orderPrice >= 0.0 : ["orderPrice >= 0.0", orderPrice];
			assert orderVolume >= 0 : ["orderVolume >= 0", orderVolume];
		}
		if (secondary$expectedFuturePrice < secondary.getMarketPrice(t)) {
			orderPrice = secondary$expectedFuturePrice * (1 + marginWidth);
			if (0.0 < orderPrice && orderPrice <= highestBuyPrice) {
				orderPrice = highestBuyPrice;
				//Console.OUT.println("SELL_MARKET_ORDER-like");
			}
			orderVolume = 1;
			if (orderVolume > 0) {
				orders.add(new Order(Order.KIND_SELL_LIMIT_ORDER, agent, secondary, orderPrice, orderVolume, timeWindowSize));
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

	public def chooseAlternativeMarket(primary:Market, secondary:Set[Market]):Market {
		/* return null; */
		val t = Global.TIME.get();
		val styleCoefficient = (1.0 + fundamentalWeight) / (1.0 + chartWeight);
		val timeWindowSizeMax = this.timeWindowSizeMin + Math.ceil(this.timeWindowSizeScale * styleCoefficient) as Long;
		val timeWindowSize = Math.min(t, timeWindowSizeMax);

		val options = new ArrayList[Market]();
		val weights = new ArrayList[Double]();
		for (m in secondary) {
			if (m.isRunning()) {
				if (!Global.STATISTICS.exists(primary.marketReturns, m.marketReturns, timeWindowSizeMax)) {
					Global.STATISTICS.register(primary.marketReturns, m.marketReturns, timeWindowSizeMax, (x:Double)=>Math.log(x));
				}
				val r = Global.STATISTICS.corrcoef(primary.marketReturns, m.marketReturns, timeWindowSizeMax);
				options.add(m);
				weights.add(Math.abs(r));
			}
		}
		if (options.size() == 0) {
			return null; // No market available.
		}
		if (options.size() == 1) {
			return options(0);
		}
		val i = Statistics.roulette(weights);
		return options(i);
	}
}

