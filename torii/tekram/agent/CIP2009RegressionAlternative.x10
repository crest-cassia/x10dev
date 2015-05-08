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
public class CIP2009RegressionAlternative extends CIP2009 implements AlterOrderMaking {

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

//		if (agent.getCashAmount() <= 0.0 || secondary$tempAssetVolume <= 0) {
//			return orders; // Stop thinking.
//		}

		val random = new Random();
		val gaussian = new Gaussian(random);

		val styleCoefficient = (1.0 + fundamentalWeight) / (1.0 + chartWeight);
		val timeWindowSizeMax = this.timeWindowSizeMin + Math.ceil(this.timeWindowSizeScale * styleCoefficient) as Long;
		val timeWindowSize = Math.min(t, timeWindowSizeMax);
		val riskAversionConstant = this.riskAversionScale * styleCoefficient;
		val chartStyle = (this.isChartFollowing ? +1.0 : -1.0);
		assert timeWindowSize > 0 : "timeWindowSize > 0";
		assert riskAversionConstant > 0.0 : "riskAversionConstant > 0.0";

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

//		var primary$chartSumLogReturn:Double = 0.0; // Statistics.sum(primary.marketReturns.subList(t - timeWindowSize + 1, t + 1));
//		for (j in 0..(timeWindowSize - 1)) {
//			primary$chartSumLogReturn += Math.log(primary.getMarketReturn(t - j));
//		}
//		val primary$chartMeanLogReturn = primary$chartSumLogReturn / timeWindowSize;
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

//		var primary$chartSSELogReturn:Double = 0.0;
//		for (j in 0..(timeWindowSize - 1)) {
//			primary$chartSSELogReturn += Math.pow((Math.log(primary.getMarketReturn(t - j)) - primary$chartMeanLogReturn), 2.0);
//		}
//		val primary$chartVarianceLogReturn = primary$chartSSELogReturn / timeWindowSize;
		val primary$chartVarianceLogReturn = Global.STATISTICS.variance(primary.marketReturns, timeWindowSizeMax);
		if (primary$chartVarianceLogReturn <= 1e-32) {
			return orders; // Stop thinking.
		}

		//////////////////////////////
//		var secondary$chartSumLogReturn:Double = 0.0; // Statistics.sum(secondary.marketReturns.subList(t - timeWindowSize + 1, t + 1));
//		for (j in 0..(timeWindowSize - 1)) {
//			secondary$chartSumLogReturn += Math.log(secondary.getMarketReturn(t - j));
//		}
//		val secondary$chartMeanLogReturn = secondary$chartSumLogReturn / timeWindowSize;
		val secondary$chartMeanLogReturn = Global.STATISTICS.mean(secondary.marketReturns, timeWindowSizeMax);
		assert isFinite(secondary$chartMeanLogReturn) : "isFinite(secondary$chartMeanLogReturn)";

//		var secondary$chartSSELogReturn:Double = 0.0;
//		for (j in 0..(timeWindowSize - 1)) {
//			secondary$chartSSELogReturn += Math.pow((Math.log(secondary.getMarketReturn(t - j)) - secondary$chartMeanLogReturn), 2.0);
//		}
//		val secondary$chartVarianceLogReturn = secondary$chartSSELogReturn / timeWindowSize;
		val secondary$chartVarianceLogReturn = Global.STATISTICS.variance(secondary.marketReturns, timeWindowSizeMax);
		if (secondary$chartVarianceLogReturn <= 1e-32) {
			return orders; // Stop thinking.
		}

//		var joint$chartSSELogReturn:Double = 0.0;
//		for (j in 0..(timeWindowSize - 1)) {
//			joint$chartSSELogReturn += (Math.log(primary.getMarketReturn(t - j)) - primary$chartMeanLogReturn) * (Math.log(secondary.getMarketReturn(t - j)) - secondary$chartMeanLogReturn);
//		}
//		val joint$chartVarianceLogReturn = joint$chartSSELogReturn / timeWindowSize;
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

		if (Global.DEBUG > 0) {
			Console.OUT.println("this.fundamentalWeight " + this.fundamentalWeight);
			Console.OUT.println("this.chartWeight " + this.chartWeight);
			Console.OUT.println("this.noiseWeight " + this.noiseWeight);
			Console.OUT.println("assetsVolumes(primary) " + agent.getAssetVolume(primary));
			Console.OUT.println("cashAmount " + agent.getCashAmount());
			Console.OUT.println("riskAversionConstant " + riskAversionConstant);
			Console.OUT.println("primary$expectedLogReturn " + primary$expectedLogReturn);
			Console.OUT.println("primary$expectedFuturePrice " + primary$expectedFuturePrice);
			Console.OUT.println("primary$fundamentalLogReturn " + primary$fundamentalLogReturn);
			Console.OUT.println("(primary$fundamentalScale * primary$fundamentalLogReturn) " + (primary$fundamentalScale * primary$fundamentalLogReturn));
			Console.OUT.println("primary$chartMeanLogReturn " + primary$chartMeanLogReturn);
			Console.OUT.println("primary$noiseLogReturn " + primary$noiseLogReturn);
			Console.OUT.println("primary$expectedFuturePrice " + primary$expectedFuturePrice);
			Console.OUT.println("primary$chartVarianceLogReturn " + primary$chartVarianceLogReturn);
		}

		val pi = (x:Double) => Math.log(secondary$expectedFuturePrice / x) / (riskAversionConstant * secondary$chartVarianceLogReturn * x);
		val fs = (x:Double) => Math.log(secondary$expectedFuturePrice) - Math.log(x) - riskAversionConstant * secondary$chartVarianceLogReturn * secondary$tempAssetVolume * x;
		val fm = (x:Double) => Math.log(secondary$expectedFuturePrice) - Math.log(x) - riskAversionConstant * secondary$chartVarianceLogReturn * (secondary$tempAssetVolume * x + agent.getCashAmount());

		var priceMaximal:Double;
		var priceOptimal:Double;
		var priceMinimal:Double;
		try {
			priceMaximal = secondary$expectedFuturePrice;
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

		val highestBuyPrice = secondary.getBuyOrderBook().getBestPrice();
		val lowestSellPrice = secondary.getSellOrderBook().getBestPrice();
		var orderPrice:Double = random.nextDouble() * (priceMaximal - priceMinimal) + priceMinimal;
		var orderVolume:Long = 0;
		assert priceMinimal <= orderPrice;
		assert orderPrice <= priceMaximal;

		if (orderPrice < priceOptimal) {
			if (orderPrice >= lowestSellPrice && lowestSellPrice > priceMinimal) {
				orderPrice = lowestSellPrice;
				//Console.OUT.println("BUY_MARKET_ORDER-like");
			}
			orderVolume = (pi(orderPrice) - secondary$tempAssetVolume) as Long;
			if (orderVolume > 0) {
				orders.add(new Order(Order.KIND_BUY_LIMIT_ORDER, agent, secondary, orderPrice, orderVolume, timeWindowSize));
				//Console.OUT.println("Submitted a buy order");
			}
			assert orderPrice >= 0.0 : "orderPrice >= 0.0";
			assert orderVolume >= 0 : "orderVolume >= 0";
			assert agent.getCashAmount() >= orderPrice * orderVolume : "agent.getCashAmount() >= orderPrice * orderVolume";
		}
		if (orderPrice > priceOptimal) {
			if (orderPrice <= highestBuyPrice && highestBuyPrice < priceMaximal) {
				orderPrice = highestBuyPrice;
				//Console.OUT.println("SELL_MARKET_ORDER-like");
			}
			orderVolume = (secondary$tempAssetVolume - pi(orderPrice)) as Long;
			if (orderVolume > 0) {
				orders.add(new Order(Order.KIND_SELL_LIMIT_ORDER, agent, secondary, orderPrice, orderVolume, timeWindowSize));
				//Console.OUT.println("Submitted a sell order");
			}
			assert orderPrice >= 0.0 : "orderPrice >= 0.0";
			assert orderVolume >= 0 : "orderVolume >= 0";
			assert secondary$tempAssetVolume >= orderVolume : "secondary$tempAssetVolume >= orderVolume";
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
				val r = Global.STATISTICS.corrcoef(primary.marketPrices, m.marketPrices, timeWindowSizeMax);
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

