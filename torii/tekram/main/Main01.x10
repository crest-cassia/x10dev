package tekram.main;
import x10.util.ArrayList;
import x10.util.HashMap;
import x10.util.List;
import x10.util.Option;
import x10.util.OptionsParser;
import x10.util.Random;
import x10.util.StringUtil;
import tekram.Agent;
import tekram.Global;
import tekram.IndexMarket;
import tekram.Market;
import tekram.Order;
import tekram.agent.CIP2009Agent;
import tekram.market.AverageIndexMarket;
import tekram.marketrule.CircuitBreaker;
import tekram.marketrule.MarketRule;
import tekram.util.Cholesky;
import tekram.util.Gaussian;
import tekram.util.GeomBrownian;
import tekram.util.MultiGeomBrownian;
import tekram.util.RandomPermutation;

public class Main01 {

	/**
	 * http://en.wikipedia.org/wiki/Exponential_distribution
	 * http://en.wikipedia.org/wiki/Laplace_distribution
	 */
	public static def nextExponential(random:Random, lambda:Double) {
		return lambda * -Math.log(random.nextDouble());
	}

	public static def isAgentWaitingAnyOrders(agent:Agent, markets:List[Market]) {
		for (market in markets) {
			if (market.containsOrderOf(agent)) {
				return true;
			}
		}
		return false;
	}

	public static def countAgentsWaitingAnyOrders(agents:List[Agent], markets:List[Market]):Long {
		var n:Long = 0;
		for (agent in agents) {
			if (isAgentWaitingAnyOrders(agent, markets)) {
				n += 1;
			}
		}
		return n;
	}

	public static def print(t:Long, agents:List[Agent], markets:List[Market], orders:List[Order]) {
		var sumCashAmount:Double = 0.0;
		var maxCashAmount:Double = Double.MIN_VALUE;
		var minCashAmount:Double = Double.MAX_VALUE;
		var sumWealth:Double = 0.0;
		var maxWealth:Double = Double.MIN_VALUE;
		var minWealth:Double = Double.MAX_VALUE;
		for (agent in agents) {
			var cashAmount:Double = agent.getCashAmount();
			var wealth:Double = 0.0;
			for (market in markets) {
				if (agent.isMarketAccessible(market)) {
					wealth += market.getPrice(t) * agent.getAssetVolume(market);
				}
			}
			sumCashAmount += cashAmount;
			maxCashAmount = Math.max(maxCashAmount, cashAmount);
			minCashAmount = Math.min(minCashAmount, cashAmount);
			sumWealth += wealth;
			maxWealth = Math.max(maxWealth, wealth);
			minWealth = Math.min(minWealth, wealth);
		}

		var sumMarketPrice:Double = 0.0;
		var maxMarketPrice:Double = Double.MIN_VALUE;
		var minMarketPrice:Double = Double.MAX_VALUE;
		var sumPriceChange:Double = 0.0;
		var maxPriceChange:Double = Double.MIN_VALUE;
		var minPriceChange:Double = Double.MAX_VALUE;
		for (market in markets) {
			val marketPrice = market.getPrice(t);
			val priceChange = market.getPrice(t) - market.getPrice(t - 1);
			sumMarketPrice += marketPrice;
			maxMarketPrice = Math.max(maxMarketPrice, marketPrice);
			minMarketPrice = Math.min(minMarketPrice, marketPrice);
			sumPriceChange += priceChange;
			maxPriceChange = Math.max(maxPriceChange, priceChange);
			minPriceChange = Math.min(minPriceChange, priceChange);
		}

		var totalOrdersCount:Long = orders.size();
		var primaryUseCount:Long = 0;
		var secondaryUseCount:Long = 0;
		var primaryCashAmount:Double = 0.0;
		var secondaryCashAmount:Double = 0.0;
		var primaryAssetVolume:Double = 0.0;
		var secondaryAssetVolume:Double = 0.0;
		for (order in orders) {
			// NOTE: The volume might be zero if it's been executed.
			val agent = order.getAgent();
			val market = order.getMarket();
			if (agent.isPrimaryMarket(market)) {
				primaryUseCount++;
				primaryCashAmount += agent.getCashAmount();
				primaryAssetVolume += agent.getAssetVolume(market);
			}
			if (agent.isSecondaryMarket(market)) {
				secondaryUseCount++;
				secondaryCashAmount += agent.getCashAmount();
				secondaryAssetVolume += agent.getAssetVolume(market);
			}
		}
		assert primaryUseCount + secondaryUseCount == totalOrdersCount : "primaryUseCount + secondaryUseCount == totalOrdersCount";
		var primaryUseRate:Double = 0.0;
		var secondaryUseRate:Double = 0.0;
		var meanPrimaryCashAmount:Double = 0.0;
		var meanSecondaryCashAmount:Double = 0.0;
		var meanPrimaryAssetVolume:Double = 0.0;
		var meanSecondaryAssetVolume:Double = 0.0;
		if (totalOrdersCount > 0) {
			primaryUseRate = primaryUseCount / totalOrdersCount;
			secondaryUseRate = secondaryUseCount / totalOrdersCount;
			primaryCashAmount /= totalOrdersCount;
			secondaryCashAmount /= totalOrdersCount;
			primaryAssetVolume /= totalOrdersCount;
			secondaryAssetVolume /= totalOrdersCount;
		}

		for (market in markets) {
			Console.OUT.println(StringUtil.formatArray([
		/*  0 */"DATA",
				t, 
				market.id,
				(market.isRunning() ? 1 : 0),
				market.getPrice(t),
		/*  5 */market.getReturn(t),
				market.getFundamentalPrice(t),
				market.getFundamentalReturn(t),
				(market.getPrice(t) - market.getPrice(t - 1)),
				market.buyOrdersCountsHistory(t),
		/* 10 */market.sellOrdersCountsHistory(t),
				market.executedOrdersCountsHistory(t),
				market.getLastExecutedPrice(t),
				market.getBuyOrderBook().getHighestPrice(),
				market.getSellOrderBook().getLowestPrice(),
		/* 15 */market.buyOrderBook.size(),
				market.sellOrderBook.size(),
				countAgentsWaitingAnyOrders(agents, markets),
				sumCashAmount / agents.size(),
				maxCashAmount,
		/* 20 */minCashAmount,
				sumWealth / agents.size(),
				maxWealth,
				minWealth,
				sumMarketPrice / markets.size(),
		/* 25 */maxMarketPrice,
				minMarketPrice,
				sumPriceChange / markets.size(),
				maxPriceChange,
				minPriceChange,
		/* 30 */totalOrdersCount,
				primaryUseCount,
				secondaryUseCount,
				primaryUseRate,
				secondaryUseRate,
		/* 35 */primaryCashAmount/*Average*/,
				secondaryCashAmount/*Average*/,
				primaryAssetVolume/*Average*/,
				secondaryAssetVolume/*Average*/,
				"", ""], " ", "", Int.MAX_VALUE));
		}
	}

	public static class MarketAttack {
		
		public var market:Market;
		public var time:Long;
		public var priceImpact:Double;
		public var volumeImpact:Double;

		public def this(market:Market, time:Long, priceImpact:Double, volumeImpact:Double) {
			this.market = market;
			this.time = time;
			this.priceImpact = priceImpact;
			this.volumeImpact = volumeImpact;
			assert 0.0 <= priceImpact && priceImpact <= 2.0 : "0.0 <= priceImpact <= 2.0";
			assert 0.0 <= volumeImpact && volumeImpact <= 1.0 : "0.0 <= volumeImpact <= 1.0";
		}

		public def update() {
			val t = Market.TIME.get();
			val market = this.market;
			val agent = new Agent(-1);
			agent.addPrimaryMarket(market, 1.0);
			agent.setAssetVolume(market, Long.MAX_VALUE / 2); // Long.MAX_VALUE + 1 == LONG.MIN_VALUE;
			agent.setCashAmount(Double.MAX_VALUE / 2);
			if (t == this.time) {
				if (this.market.isRunning()) {
					if (this.priceImpact <= 1.0) {
						val basePrice = market.getSellOrderBook().getLowestPrice();
						val orderPrice = basePrice * this.priceImpact;
						val volumeBetween = market.getBuyOrderBook().getTotalVolume((order:Order) => order.getPrice() >= orderPrice);
						val orderVolume = (volumeBetween * (1.0 + this.volumeImpact) + 1) as Long; // Execute all buy orders higher than that price and remain some impact.
						val timeLength = Long.MAX_VALUE / 2;
						val order = new Order(Order.KIND_SELL_LIMIT_ORDER, agent, market, orderPrice, orderVolume, timeLength);
						val dummy = new Order(Order.KIND_BUY_LIMIT_ORDER, agent, market, orderPrice, 1, timeLength);
						market.handleOrder(dummy);
						market.handleOrder(order);
						Console.OUT.println("# MARKET ATTACK: placed a sell order " + order + "(volume " + order.getVolume() + ")");
						if (orderVolume == 0) {
							Console.OUT.println("# MARKET ATTACK FAILED (maybe no order in the book)");
						}
					} else {
						val basePrice = market.getBuyOrderBook().getHighestPrice();
						val orderPrice = basePrice * this.priceImpact;
						val volumeBetween = market.getSellOrderBook().getTotalVolume((order:Order) => order.getPrice() <= orderPrice);
						val orderVolume = (volumeBetween * (1.0 + this.volumeImpact) + 1) as Long; // Execute all sell orders lower than that price and remain some impact.
						val timeLength = Long.MAX_VALUE / 2;
						val order = new Order(Order.KIND_BUY_LIMIT_ORDER, agent, market, orderPrice, orderVolume, timeLength);
						val dummy = new Order(Order.KIND_SELL_LIMIT_ORDER, agent, market, orderPrice, 1, timeLength);
						market.handleOrder(dummy);
						market.handleOrder(order);
						Console.OUT.println("# MARKET ATTACK: placed a buy order " + order + "(volume " + order.getVolume() + ")");
						if (orderVolume == 0) {
							Console.OUT.println("# MARKET ATTACK FAILED (maybe no order in the book)");
						}
					}
				}
			}
		}
	}

	public static def main(args:Rail[String]) {
		val MAYBEMORE = true;
		val REQUIRED = true;

		val options = new ArrayList[Option]();
		options.add(new Option("", "--agents", "the number of agents per market [int|1000]",	1n, !MAYBEMORE, !REQUIRED));
		options.add(new Option("", "--markets", "the number of spot markets [int]",				1n, !MAYBEMORE,  REQUIRED));
		options.add(new Option("", "--indexmarkets", "the number of index markets [int|0]",		1n, !MAYBEMORE, !REQUIRED));
		options.add(new Option("-f", "", "average fundamental weight [float]",					1n, !MAYBEMORE,  REQUIRED));
		options.add(new Option("-c", "", "average chart weight [float]",						1n, !MAYBEMORE,  REQUIRED));
		options.add(new Option("-n", "", "average noise weight [float]",						1n, !MAYBEMORE,  REQUIRED));
		options.add(new Option("-t", "", "scale for time window size [float]",					1n, !MAYBEMORE,  REQUIRED));
		options.add(new Option("", "--corrcoef", "correlations of fundamentals [float]",		0n,  MAYBEMORE,  REQUIRED));
		options.add(new Option("", "--volatility", "volatility of fundamentals [float|0.001]",	1n,  MAYBEMORE, !REQUIRED));
		options.add(new Option("", "--secondary", "probability to choose secondary [float]",	1n, !MAYBEMORE,  REQUIRED));
		options.add(new Option("", "--marketrule", "circuit breaker (3 tuples: id change-rate, time-scale)",		3n,  MAYBEMORE, !REQUIRED));
		options.add(new Option("", "--iteration", "the number of iteration [int|5000]",			1n, !MAYBEMORE, !REQUIRED));
		options.add(new Option("", "--attack", "attack against market prices (4 tuples: which when price volume)",	4n,  MAYBEMORE, !REQUIRED));
//		options.add(new Option("-?", "--help", "show this message",								0n, !MAYBEMORE, !REQUIRED));
		options.add(OptionsParser.HELP);

		val opt = new OptionsParser(args, options.toRail());
		if (opt("help")) {
			Console.ERR.println(opt.usage("Options:\n"));
			return;
		}

		val SPOT_MARKETS_COUNT = opt("markets", 3);
		val INDEX_MARKETS_COUNT = opt("indexmarkets", 0);
		val MARKETS_COUNT = SPOT_MARKETS_COUNT + INDEX_MARKETS_COUNT;
		val MARKET_ITERATION = opt("iteration", 5000);
		val MARKET_FUNDAMENTAL_PRICE = 300.0;
		val MARKET_FUNDAMENTAL_DRIFT = 0.0;
		val MARKET_FUNDAMENTAL_VOLATILITY = opt("volatility", 0.001);

		val AGENTS_COUNT_PER_MARKET = opt("agents", 1000);
		val CIP2009AGENTS_SPOT_COUNT = AGENTS_COUNT_PER_MARKET * SPOT_MARKETS_COUNT;
		val CIP2009AGENTS_INDEX_COUNT = AGENTS_COUNT_PER_MARKET * INDEX_MARKETS_COUNT;
		val AGENTS_COUNT = CIP2009AGENTS_SPOT_COUNT + CIP2009AGENTS_INDEX_COUNT;
		val AGENT_ASSET_VOLUME_SCALE = 50; //TODO: The cash amount below is for the only primary; Fix it if more than one.
		val AGENT_CASH_AMOUNT_SCALE = AGENT_ASSET_VOLUME_SCALE * MARKET_FUNDAMENTAL_PRICE; // TODO: Add some for secondaries?
		val CIP2009AGENT_FUNDAMENTAL_WEIGHT_SCALE = opt("f", 10.000001);
		val CIP2009AGENT_CHART_WEIGHT_SCALE = opt("c", 2.000001);
		val CIP2009AGENT_NOISE_WEIGHT_SCALE = opt("n", 1.000001);
		val CIP2009AGENT_AVERAGE_STYLE_COEFFICIENT = (1.0 + CIP2009AGENT_FUNDAMENTAL_WEIGHT_SCALE) / (1.0 + CIP2009AGENT_CHART_WEIGHT_SCALE);
		val CIP2009AGENT_AVERAGE_TIME_WINDOW_SIZE = CIP2009AGENT_TIME_WINDOW_SIZE_SCALE * CIP2009AGENT_AVERAGE_STYLE_COEFFICIENT;
		val AGENT_SECONDARY_ASSETS_SCALE = 0.5;
		val AGENT_SECONDARY_PROBABILITY = opt("secondary", 1.0);

		val CIP2009AGENT_CHART_FOLLOWERS_CHANCE = 1.0;
		val CIP2009AGENT_TIME_WINDOW_SIZE_SCALE = opt("t", 100.0);
		val CIP2009AGENT_FUNDAMENTAL_MEAN_REVERSION_TIME = CIP2009AGENT_TIME_WINDOW_SIZE_SCALE; // NOTE: No info in CIP (2009).

		Console.OUT.println("# SPOT_MARKETS_COUNT " + SPOT_MARKETS_COUNT);
		Console.OUT.println("# INDEX_MARKETS_COUNT " + INDEX_MARKETS_COUNT);
		Console.OUT.println("# MARKETS_COUNT " + MARKETS_COUNT);
		Console.OUT.println("# MARKET_ITERATION " + MARKET_ITERATION);
		Console.OUT.println("# MARKET_FUNDAMENTAL_PRICE " + MARKET_FUNDAMENTAL_PRICE);
		Console.OUT.println("# MARKET_FUNDAMENTAL_DRIFT " + MARKET_FUNDAMENTAL_DRIFT);
		Console.OUT.println("# MARKET_FUNDAMENTAL_VOLATILITY " + MARKET_FUNDAMENTAL_VOLATILITY);
		Console.OUT.println("# AGENTS_COUNT_PER_MARKET " + AGENTS_COUNT_PER_MARKET);
		Console.OUT.println("# CIP2009AGENTS_SPOT_COUNT " + CIP2009AGENTS_SPOT_COUNT);
		Console.OUT.println("# CIP2009AGENTS_INDEX_COUNT " + CIP2009AGENTS_INDEX_COUNT);
		Console.OUT.println("# AGENTS_COUNT " + AGENTS_COUNT);
		Console.OUT.println("# AGENT_ASSET_VOLUME_SCALE " + AGENT_ASSET_VOLUME_SCALE);
		Console.OUT.println("# AGENT_CASH_AMOUNT_SCALE " + AGENT_CASH_AMOUNT_SCALE);
		Console.OUT.println("# AGENT_SECONDARY_ASSETS_SCALE " + AGENT_SECONDARY_ASSETS_SCALE);
		Console.OUT.println("# AGENT_SECONDARY_PROBABILITY " + AGENT_SECONDARY_PROBABILITY);
		Console.OUT.println("# CIP2009AGENT_FUNDAMENTAL_WEIGHT_SCALE " + CIP2009AGENT_FUNDAMENTAL_WEIGHT_SCALE);
		Console.OUT.println("# CIP2009AGENT_CHART_WEIGHT_SCALE " + CIP2009AGENT_CHART_WEIGHT_SCALE);
		Console.OUT.println("# CIP2009AGENT_NOISE_WEIGHT_SCALE " + CIP2009AGENT_NOISE_WEIGHT_SCALE);
		Console.OUT.println("# CIP2009AGENT_CHART_FOLLOWERS_CHANCE " + CIP2009AGENT_CHART_FOLLOWERS_CHANCE);
		Console.OUT.println("# CIP2009AGENT_TIME_WINDOW_SIZE_SCALE " + CIP2009AGENT_TIME_WINDOW_SIZE_SCALE);
		Console.OUT.println("# CIP2009AGENT_AVERAGE_STYLE_COEFFICIENT " + CIP2009AGENT_AVERAGE_STYLE_COEFFICIENT);
		Console.OUT.println("# CIP2009AGENT_AVERAGE_TIME_WINDOW_SIZE " + CIP2009AGENT_AVERAGE_TIME_WINDOW_SIZE);
//		Console.OUT.println("#  " + );

		// The number of agents, total cash amount, strategy ratio.
		
		val s0 = new Rail[Double](SPOT_MARKETS_COUNT);
		val mu = new Rail[Double](SPOT_MARKETS_COUNT);
		val sigma = new Rail[Double](SPOT_MARKETS_COUNT);
		val cor = new Rail[Rail[Double]](SPOT_MARKETS_COUNT);
		for (i in 0..(SPOT_MARKETS_COUNT - 1)) {
			cor(i) = new Rail[Double](SPOT_MARKETS_COUNT);
		}
		if (SPOT_MARKETS_COUNT == 1) {
			assert opt.get("corrcoef").size == 0 : "The option --corrcoef must have 0 arguments";
			s0(0) = MARKET_FUNDAMENTAL_PRICE;
			mu(0) = MARKET_FUNDAMENTAL_DRIFT;
			sigma(0) = MARKET_FUNDAMENTAL_VOLATILITY;
			cor(0)(0) = 1.0;
		}
		if (SPOT_MARKETS_COUNT == 2) {
			assert opt.get("corrcoef").size == 1 : "The option --corrcoef must have 1 arguments";
			val a = Double.parse(opt.get("corrcoef")(0));
			s0(0) = s0(1) = MARKET_FUNDAMENTAL_PRICE;
			mu(0) = mu(1) = MARKET_FUNDAMENTAL_DRIFT;
			sigma(0) = sigma(1) = MARKET_FUNDAMENTAL_VOLATILITY;
			cor(0)(0) = 1.0; cor(0)(1) =  a ;
			cor(1)(0) =  a ; cor(1)(1) = 1.0;
		}
		if (SPOT_MARKETS_COUNT == 3) {
			assert opt.get("corrcoef").size == 2 : "The option --corrcoef must have 2 arguments";
			val a = Double.parse(opt.get("corrcoef")(0));
			val b = Double.parse(opt.get("corrcoef")(1));
			s0(0) = s0(1) = s0(2) = MARKET_FUNDAMENTAL_PRICE;
			mu(0) = mu(1) = mu(2) = MARKET_FUNDAMENTAL_DRIFT;
			sigma(0) = sigma(1) = sigma(2) = MARKET_FUNDAMENTAL_VOLATILITY;
			cor(0)(0) = 1.0; cor(0)(1) =  a ; cor(0)(2) =  b ;
			cor(1)(0) =  a ; cor(1)(1) = 1.0; cor(1)(2) =  b ;
			cor(2)(0) =  b ; cor(2)(1) =  b ; cor(2)(2) = 1.0;
		}
		if (SPOT_MARKETS_COUNT == 4) {
			assert opt.get("corrcoef").size == 3 : "The option --corrcoef must have 3 arguments";
			val a = Double.parse(opt.get("corrcoef")(0));
			val b = Double.parse(opt.get("corrcoef")(1));
			val c = Double.parse(opt.get("corrcoef")(2));
			s0(0) = s0(1) = s0(2) = s0(3) = MARKET_FUNDAMENTAL_PRICE;
			mu(0) = mu(1) = mu(2) = mu(3) = MARKET_FUNDAMENTAL_DRIFT;
			sigma(0) = sigma(1) = sigma(2) = sigma(3) = MARKET_FUNDAMENTAL_VOLATILITY;
			cor(0)(0) = 1.0; cor(0)(1) =  a ; cor(0)(2) =  c ; cor(0)(3) =  c ;
			cor(1)(0) =  a ; cor(1)(1) = 1.0; cor(1)(2) =  c ; cor(1)(3) =  c ;
			cor(2)(0) =  c ; cor(2)(1) =  c ; cor(2)(2) = 1.0; cor(2)(3) =  b ;
			cor(3)(0) =  c ; cor(3)(1) =  c ; cor(3)(2) =  b ; cor(3)(3) = 1.0;
		}

		val random = new Random();
		val chol = Cholesky.decompose(cor);
		val dt = 1.0;
		val fundamentals = new MultiGeomBrownian(random, mu, sigma, chol, s0, dt);
		fundamentals.nextBrownian();

		Console.OUT.println("# GEOMETRIC BROWNIANS");
		Console.OUT.println("#   s0 " + s0);
		Console.OUT.println("#   mu " + mu);
		Console.OUT.println("#   sigma " + sigma);
		Console.OUT.println("#   cor " + cor);

		val markets = new ArrayList[Market]();

		val spotMarkets = new ArrayList[Market]();
		for (i in 0..(SPOT_MARKETS_COUNT - 1)) {
			val id = markets.size();
			val market = new Market(id);
			val initialFundamental = fundamentals.get(id);
			val initialPrice = initialFundamental;
			market.setInitialPrice(initialPrice);
			market.setInitialFundamentalPrice(initialFundamental);
			markets.add(market);
			spotMarkets.add(market);

			Console.OUT.println("# SPOT MARKET " + id);
			Console.OUT.println("#   initialMarketPrice " + initialPrice);
			Console.OUT.println("#   initialFundamentalPrice " + initialFundamental);
		}

		val indexMarkets = new ArrayList[IndexMarket]();
		for (i in 0..(INDEX_MARKETS_COUNT - 1)) {
			val id = markets.size();
			val market = new AverageIndexMarket(id);
			for (spotMarket in spotMarkets) {
				market.addMarket(spotMarket);
			}
			val initialFundamental = market.computeIndexPrice();
			val initialPrice = initialFundamental;
			market.setInitialPrice(initialPrice);
			market.setInitialFundamentalPrice(initialFundamental);
			markets.add(market);
			indexMarkets.add(market);

			Console.OUT.println("# INDEX MARKET " + id);
			Console.OUT.println("#   initialMarketPrice " + initialPrice);
			Console.OUT.println("#   initialFundamentalPrice " + initialFundamental);
		}

		var LARGEST_TIME_WINDOW_SIZE:Long = Long.MIN_VALUE;
		val agents = new ArrayList[Agent]();

		for (i in 0..(CIP2009AGENTS_SPOT_COUNT - 1)) {
			val id = agents.size();
			val fundamentalWeight = nextExponential(random, CIP2009AGENT_FUNDAMENTAL_WEIGHT_SCALE);
			val chartWeight = nextExponential(random, CIP2009AGENT_CHART_WEIGHT_SCALE);
			val noiseWeight = nextExponential(random, CIP2009AGENT_NOISE_WEIGHT_SCALE);
			val isChartFollowing = (random.nextDouble() < CIP2009AGENT_CHART_FOLLOWERS_CHANCE);
			val agent = new CIP2009Agent(id, fundamentalWeight, chartWeight, noiseWeight);
			agent.setTimeWindowSize(CIP2009AGENT_TIME_WINDOW_SIZE_SCALE);
			agent.setFundamentalMeanReversionTime(CIP2009AGENT_FUNDAMENTAL_MEAN_REVERSION_TIME);
			val m = random.nextLong(spotMarkets.size());
			val initialAssetVolume = random.nextLong(AGENT_ASSET_VOLUME_SCALE);
			agent.addPrimaryMarket(spotMarkets(m), 1.0);
			agent.setAssetVolume(spotMarkets(m), initialAssetVolume);
			agent.setChoosingSecondaryProbability(AGENT_SECONDARY_PROBABILITY);
			for (n in 0..(spotMarkets.size() - 1)) {
				if (n != m) {
					agent.addSecondaryMarket(spotMarkets(n), cor(n)(m));
					agent.setAssetVolume(spotMarkets(n), ((initialAssetVolume * AGENT_SECONDARY_ASSETS_SCALE) / (spotMarkets.size() - 1)) as Long);
				}
			}
			val initialCashAmount = random.nextDouble() * AGENT_CASH_AMOUNT_SCALE;
			agent.setCashAmount(initialCashAmount);
			agents.add(agent);

			LARGEST_TIME_WINDOW_SIZE = Math.max(agent.timeWindowSize, LARGEST_TIME_WINDOW_SIZE);
		}

		for (i in 0..(CIP2009AGENTS_INDEX_COUNT - 1)) {
			val id = agents.size();
			val fundamentalWeight = nextExponential(random, CIP2009AGENT_FUNDAMENTAL_WEIGHT_SCALE);
			val chartWeight = nextExponential(random, CIP2009AGENT_CHART_WEIGHT_SCALE);
			val noiseWeight = nextExponential(random, CIP2009AGENT_NOISE_WEIGHT_SCALE);
			val isChartFollowing = (random.nextDouble() < CIP2009AGENT_CHART_FOLLOWERS_CHANCE);
			val agent = new CIP2009Agent(id, fundamentalWeight, chartWeight, noiseWeight);
			agent.setTimeWindowSize(CIP2009AGENT_TIME_WINDOW_SIZE_SCALE);
			agent.setFundamentalMeanReversionTime(CIP2009AGENT_FUNDAMENTAL_MEAN_REVERSION_TIME);
			val m = random.nextLong(indexMarkets.size());
			val initialAssetVolume = random.nextLong(AGENT_ASSET_VOLUME_SCALE);
			agent.addPrimaryMarket(indexMarkets(m), 1.0);
			agent.setAssetVolume(indexMarkets(m), initialAssetVolume);
			agent.setChoosingSecondaryProbability(AGENT_SECONDARY_PROBABILITY);
			for (n in 0..(indexMarkets.size() - 1)) {
				if (n != m) {
					agent.addSecondaryMarket(indexMarkets(n), cor(n)(m));
					agent.setAssetVolume(spotMarkets(n), ((initialAssetVolume * AGENT_SECONDARY_ASSETS_SCALE) / (spotMarkets.size() - 1)) as Long);
				}
			}
			val initialCashAmount = random.nextDouble() * AGENT_CASH_AMOUNT_SCALE;
			agent.setCashAmount(initialCashAmount);
			agents.add(agent);

			LARGEST_TIME_WINDOW_SIZE = Math.max(agent.timeWindowSize, LARGEST_TIME_WINDOW_SIZE);
		}

		assert opt.get("marketrule").size % 3 == 0 : "The option --marketrule must be 3-tuples";
		val marketRules = new ArrayList[MarketRule]();
		for (i in 0..(opt.get("marketrule").size / 3 - 1)) {
			val arg1 = opt.get("marketrule")(i * 3 + 0);
			val arg2 = opt.get("marketrule")(i * 3 + 1);
			val arg3 = opt.get("marketrule")(i * 3 + 2);
			val id = Long.parse(arg1);
			val basePrice = MARKET_FUNDAMENTAL_PRICE;
			val changeRate = Double.parse(arg2);
			val timeLength = (CIP2009AGENT_AVERAGE_TIME_WINDOW_SIZE * Double.parse(arg3)) as Long;
			marketRules.add(new CircuitBreaker(markets(id), basePrice, changeRate, timeLength));

			Console.OUT.println("# CIRCUIT BREAKER");
			Console.OUT.println("#   market.id " + id);
			Console.OUT.println("#   basePrice " + basePrice);
			Console.OUT.println("#   changeRate " + changeRate);
			Console.OUT.println("#   timeLength " + timeLength);
		}

		assert opt.get("attack").size % 4 == 0 : "The option --attack must be 4-tuples";
		val marketAttacks = new ArrayList[MarketAttack]();
		for (i in 0..(opt.get("attack").size / 4 - 1)) {
			val arg1 = opt.get("attack")(i * 4 + 0);
			val arg2 = opt.get("attack")(i * 4 + 1);
			val arg3 = opt.get("attack")(i * 4 + 2);
			val arg4 = opt.get("attack")(i * 4 + 3);
			val id   = Long.parse(arg1);
			val time = Long.parse(arg2); // >= 1
			val priceImpact  = Double.parse(arg3);
			val volumeImpact = Double.parse(arg4);
			marketAttacks.add(new MarketAttack(markets(id), LARGEST_TIME_WINDOW_SIZE + time, priceImpact, volumeImpact));

			Console.OUT.println("# MARKET ATTACK (no." + i + ")");
			Console.OUT.println("#   market.id " + id);
			Console.OUT.println("#   time " + time);
			Console.OUT.println("#   priceImpact " + priceImpact);
			Console.OUT.println("#   volumeImpact " + volumeImpact);
		}
		
		Console.OUT.println("# LARGEST_TIME_WINDOW_SIZE " + LARGEST_TIME_WINDOW_SIZE);
		Console.OUT.println("# MARKET_CLOSE_TIME " + (LARGEST_TIME_WINDOW_SIZE + MARKET_ITERATION));

		Market.TIME.set(1);
		

		// To fill with fundamental prices/returns, to initiate the trends.
		for (t in 1..LARGEST_TIME_WINDOW_SIZE) {
			fundamentals.nextBrownian();
			for (market in spotMarkets) {
				val nextFundamental = fundamentals.get(market.id);
				market.updatePrice(nextFundamental);
				market.updateFundamentalPrice(nextFundamental);
				market.updateOrderBooks();
			}
			for (market in indexMarkets) {
				val nextFundamental = market.computeIndexPrice();
				market.updatePrice(nextFundamental);
				market.updateFundamentalPrice(nextFundamental);
				market.updateOrderBooks();
			}
			Market.TIME.next();
		}
		
		for (t in (LARGEST_TIME_WINDOW_SIZE + 1)..(LARGEST_TIME_WINDOW_SIZE + MARKET_ITERATION)) {
			assert t == Market.TIME.get();

			val allOrders = new ArrayList[Order]();

			val blockedMarkets = new ArrayList[Market]();
			val blockedAgents = new ArrayList[Agent]();
			val randomMarkets = new RandomPermutation[Market](random, markets);
			val randomAgents = new RandomPermutation[Agent](random, agents);

			if (false) {
				/* ONE-AGENT ONE-ORDER (TO ONE-MARKET) RULE.
				 * Under this rule, no agent can submit more than one order; hence no arbitragers. */
				randomMarkets.shuffle();
				for (market in randomMarkets) {
					randomAgents.shuffle();
					for (agent in randomAgents) {
						if (blockedAgents.contains(agent)) {
							continue;
						}
						// Prohibit placement of any orders by agents, who have placed any orders in any markets.
						if (!isAgentWaitingAnyOrders(agent, markets)) {
							val orders = agent.placeOrders(market);
							if (orders.size() > 0) {
								assert orders.size() == 1;
								val order = orders(0);
								market.handleOrder(order);
								allOrders.add(order);
								blockedAgents.add(agent);
								break; // Next market.
							}
						}
					}
				}
			}

			if (true) {
				/* ONE-MARKET ONE-ORDER (SOME ORDERS BY ONE-AGENT) RULE.
				 * Under this rule, no markets can accept more than one order; hence no arbitragers. */
				val MAX_AGENTS_DECISIONS = 100;
				var k:Long = 0;
				randomAgents.shuffle();
				for (agent in randomAgents) {
					if (blockedMarkets.size() == markets.size()) {
						break;
					}
					if (!isAgentWaitingAnyOrders(agent, markets)) {
						if (k++ >= MAX_AGENTS_DECISIONS) {
							break;
						}
						val orders = agent.placeOrders(markets); // NOTE: In one of all markets.
						if (orders.size() > 0) {
							assert orders.size() == 1;
							val order = orders(0);
							val market = order.getMarket();
							if (!blockedMarkets.contains(market)) {
								market.handleOrder(order);
								allOrders.add(order);
								blockedMarkets.add(market);
							}
						}
					}
				}
				if (Global.DEBUG > 0) {
					Console.OUT.println("  #(agents asked to make a decision) = " + k +
										", #(markets handled any order) = " + blockedMarkets.size());
				}
			}
			
			for (attack in marketAttacks) {
				attack.update();
			}

			fundamentals.nextBrownian();
			for (market in spotMarkets) {
				val nextFundamental = fundamentals.get(market.id);
				market.updatePrice();
				market.updateFundamentalPrice(nextFundamental);
				market.updateOrderBooks();
			}
			for (market in indexMarkets) {
				val nextFundamental = market.computeIndexPrice();
				market.updatePrice();
				market.updateFundamentalPrice(nextFundamental);
				market.updateOrderBooks();
			}
			
			print(t, agents, markets, allOrders);
			
			Market.TIME.next();

			for (market in markets) {
				market.check();
			}

			for (rule in marketRules) {
				rule.update();
			}
		}

		for (rule in marketRules) {
			val cbrule = rule as CircuitBreaker;
			Console.OUT.println("# #(circuit braker activated at " + cbrule.market.id + ") = " + cbrule.activationCount);
		}
	}
}
