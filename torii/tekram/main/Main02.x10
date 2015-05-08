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

public class Main02 {

	/**
	 * ONE-AGENT ONE-ORDER (TO ONE-MARKET) RULE.
	 * Under this rule, no agent can submit more than one order; hence no arbitragers.
	 */
	public static def doOneAgentOneOrderUpdate(random:Random, agents:List[Agent], markets:List[Market], allOrders:List[Order]) {
		val blockedMarkets = new ArrayList[Market]();
		val blockedAgents = new ArrayList[Agent]();
		val randomMarkets = new RandomPermutation[Market](random, markets);
		val randomAgents = new RandomPermutation[Agent](random, agents);

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

	/**
	 * ONE-MARKET ONE-ORDER (SOME ORDERS BY ONE-AGENT) RULE.
	 * Under this rule, no markets can accept more than one order; hence no arbitragers.
	 */
	public static def doOneMarketOneOrderUpdate(random:Random, agents:List[Agent], markets:List[Market], allOrders:List[Order]) {
		val blockedMarkets = new ArrayList[Market]();
		val blockedAgents = new ArrayList[Agent]();
		val randomMarkets = new RandomPermutation[Market](random, markets);
		val randomAgents = new RandomPermutation[Agent](random, agents);

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

	public static def print(phaseCode:Long, agents:List[Agent], markets:List[Market], orders:List[Order]) {
		val t = Market.TIME.get();
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

		val meanPrice100 = new HashMap[Market,Double]();
		val meanReturn100 = new HashMap[Market,Double]();
		val stdPrice100 = new HashMap[Market,Double]();
		val stdReturn100 = new HashMap[Market,Double]();
		for (market in markets) {
			val windowSize = Math.min(t, 100);
			var sumPrice:Double = 0.0;
			var sumReturn:Double = 0.0;
			var sum2Price:Double = 0.0;
			var sum2Return:Double = 0.0;
			for (j in 0..(windowSize - 1)) {
				sumPrice += market.getPrice(t - j);
				sumReturn += market.getReturn(t - j);
				sum2Price += Math.pow(market.getPrice(t - j), 2.0);
				sum2Return += Math.pow(market.getReturn(t - j), 2.0);
			}
			val meanPrice = sumPrice / windowSize;
			val meanReturn = sumReturn / windowSize;
			val mean2Price = sum2Price / windowSize;
			val mean2Return = sum2Return / windowSize;
			val stdPrice = Math.sqrt(mean2Price - Math.pow(meanPrice, 2.0));
			val stdReturn = Math.sqrt(mean2Return - Math.pow(meanReturn, 2.0));

			meanPrice100.put(market, meanPrice);
			meanReturn100.put(market, meanReturn);
			stdPrice100.put(market, stdPrice);
			stdReturn100.put(market, stdReturn);
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
				phaseCode,
				t, 
				market.id,
				(market.isRunning() ? 1 : 0),
		/*  5 */market.getPrice(t),
				market.getReturn(t),
				market.getFundamentalPrice(t),
				market.getFundamentalReturn(t),
				(market.getPrice(t) - market.getPrice(t - 1)),
		/* 10 */market.buyOrdersCountsHistory(t),
				market.sellOrdersCountsHistory(t),
				market.executedOrdersCountsHistory(t),
				market.getLastExecutedPrice(t),
				market.getBuyOrderBook().getHighestPrice(),
		/* 15 */market.getSellOrderBook().getLowestPrice(),
				market.getBuyOrderBook().size(),
				market.getSellOrderBook().size(),
				//
				market.getBuyOrderBook().getTotalPrice(),
				market.getSellOrderBook().getTotalPrice(),
				market.getBuyOrderBook().getTotalVolume(),
				market.getSellOrderBook().getTotalVolume(),
				//
				countAgentsWaitingAnyOrders(agents, markets),
				sumCashAmount / agents.size(),
		/* 20 */maxCashAmount,
				minCashAmount,
				sumWealth / agents.size(),
				maxWealth,
				minWealth,
		/* 25 */sumMarketPrice / markets.size(),
				maxMarketPrice,
				minMarketPrice,
				sumPriceChange / markets.size(),
				maxPriceChange,
		/* 30 */minPriceChange,
				totalOrdersCount,
				primaryUseCount,
				secondaryUseCount,
				primaryUseRate,
		/* 35 */secondaryUseRate,
				primaryCashAmount/*Average*/,
				secondaryCashAmount/*Average*/,
				primaryAssetVolume/*Average*/,
				secondaryAssetVolume/*Average*/,
		/* 40 */meanPrice100.get(market)(),
				meanReturn100.get(market)(),
				stdPrice100.get(market)(),
				stdReturn100.get(market)(),
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

	// The number of agents, total cash amount, strategy ratio.
		
	public static def main(args:Rail[String]) {
		val MAYBEMORE = true;
		val REQUIRED = true;

		val options = new ArrayList[Option]();
		options.add(new Option("", "--iteration", "the number of iteration [int|5000]",				1n, !MAYBEMORE, !REQUIRED));
		options.add(new Option("", "--markets", "the number of spot markets (= #S) [int]",			1n, !MAYBEMORE,  REQUIRED));
		options.add(new Option("", "--indexmarkets", "the number of index markets (= #I) [int|0]",	1n, !MAYBEMORE, !REQUIRED));
		options.add(new Option("", "--agents", "the number of agents [@int:#M]",					1n,  MAYBEMORE,  REQUIRED));
		options.add(new Option("-f", "", "average fundamental weight [@float:#M]",					1n,  MAYBEMORE,  REQUIRED));
		options.add(new Option("-c", "", "average chart weight [@float:#M]",						1n,  MAYBEMORE,  REQUIRED));
		options.add(new Option("-n", "", "average noise weight [@float:#M]",						1n,  MAYBEMORE,  REQUIRED));
		options.add(new Option("-t", "", "scale for time window size [float]",						1n, !MAYBEMORE,  REQUIRED));
		options.add(new Option("-S", "", "scale for initial assets/shares [@int:#M]",				1n,  MAYBEMORE,  REQUIRED));
		options.add(new Option("-p", "", "probability to choose secondary [@float:#M]",				1n, !MAYBEMORE,  REQUIRED));
		options.add(new Option("", "--corrcoef", "correlations of fundamentals [@float:???]",	0n,  MAYBEMORE,  REQUIRED));
		options.add(new Option("", "--volatility", "volatility of fundamentals [float|0.001]",	1n, !MAYBEMORE, !REQUIRED));
		options.add(new Option("", "--secondary", "probability to choose secondary [float]",	1n, !MAYBEMORE,  REQUIRED));
		options.add(new Option("", "--marketrule", "for circuit breakers (market-id, change-rate, time-scale) [int,float,float]",				3n,  MAYBEMORE, !REQUIRED));
		options.add(new Option("", "--attack", "for market attacks (market-id, time-at, price-impact, volume-impact) [int,int,float,float]",	4n,  MAYBEMORE, !REQUIRED));
//		options.add(new Option("-?", "--help", "show this message",								0n, !MAYBEMORE, !REQUIRED));
		options.add(OptionsParser.HELP);

		val opt = new OptionsParser(args, options.toRail());
		if (opt("help")) {
			Console.ERR.println(opt.usage("Options: (#M = #S + #I)\n"));
			return;
		}

		val SPOT_MARKETS_COUNT = opt("markets", 3);
		val INDEX_MARKETS_COUNT = opt("indexmarkets", 0);
		val MARKETS_COUNT = SPOT_MARKETS_COUNT + INDEX_MARKETS_COUNT;
		val MARKET_ITERATION = opt("iteration", 5000);
		val MARKET_FUNDAMENTAL_PRICE = 300.0;
		val MARKET_FUNDAMENTAL_DRIFT = 0.0;
		val MARKET_FUNDAMENTAL_VOLATILITY = opt("volatility", 0.001);
		val MARKET_UPDATE_ONE_AGENT_ONE_ORDER = 0x1;
		val MARKET_UPDATE_ONE_MARKET_ONE_ORDER = 0x2;
		val MARKET_UPDATE = MARKET_UPDATE_ONE_MARKET_ONE_ORDER;

		Console.OUT.println("# SPOT_MARKETS_COUNT " + SPOT_MARKETS_COUNT);
		Console.OUT.println("# INDEX_MARKETS_COUNT " + INDEX_MARKETS_COUNT);
		Console.OUT.println("# MARKETS_COUNT " + MARKETS_COUNT);
		Console.OUT.println("# MARKET_ITERATION " + MARKET_ITERATION);
		Console.OUT.println("# MARKET_FUNDAMENTAL_PRICE " + MARKET_FUNDAMENTAL_PRICE);
		Console.OUT.println("# MARKET_FUNDAMENTAL_DRIFT " + MARKET_FUNDAMENTAL_DRIFT);
		Console.OUT.println("# MARKET_FUNDAMENTAL_VOLATILITY " + MARKET_FUNDAMENTAL_VOLATILITY);
		Console.OUT.println("# MARKET_UPDATE " + MARKET_UPDATE);

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

		assert opt.get("agents").size == MARKETS_COUNT : "The option --agents must have #(markets) arguments.";
		assert opt.get("S").size == MARKETS_COUNT : "The option --volume must have #(markets) arguments.";
		assert opt.get("f").size == MARKETS_COUNT : "The option -f must have #(markets) arguments.";
		assert opt.get("c").size == MARKETS_COUNT : "The option -c must have #(markets) arguments.";
		assert opt.get("n").size == MARKETS_COUNT : "The option -n must have #(markets) arguments.";
		val AGENT_TIME_WINDOW_SIZE_SCALE = opt("t", 100.0);
		val AGENT_FUNDAMENTAL_MEAN_REVERSION_TIME = AGENT_TIME_WINDOW_SIZE_SCALE; // NOTE: No info in CIP (2009).
		val AGENT_SECONDARY_ASSETS_SCALE = opt("p", 0.5);
		val AGENT_SECONDARY_PROBABILITY = opt("secondary", 1.0);
		var LARGEST_TIME_WINDOW_SIZE:Long = Long.MIN_VALUE;
		val agents = new ArrayList[Agent]();

		val MARKET_AGENT_AVERAGE_TIME_WINDOW_SIZE = new HashMap[Market,Double](); // FIXME: Ugly.

		for (market in spotMarkets) {
			val AGENTS_COUNT = Long.parse(opt.get("agents")(market.id));
			val AGENT_ASSET_VOLUME_SCALE = Long.parse(opt.get("S")(market.id));
			val AGENT_CASH_AMOUNT_SCALE = AGENT_ASSET_VOLUME_SCALE * MARKET_FUNDAMENTAL_PRICE;
			val AGENT_FUNDAMENTAL_WEIGHT_SCALE = Double.parse(opt.get("f")(market.id));
			val AGENT_CHART_WEIGHT_SCALE = Double.parse(opt.get("c")(market.id));
			val AGENT_NOISE_WEIGHT_SCALE = Double.parse(opt.get("n")(market.id));
			val AGENT_CHART_FOLLOWERS_CHANCE = 1.0;
			val AGENT_AVERAGE_STYLE_COEFFICIENT = (1.0 + AGENT_FUNDAMENTAL_WEIGHT_SCALE) / (1.0 + AGENT_CHART_WEIGHT_SCALE);
			val AGENT_AVERAGE_TIME_WINDOW_SIZE = AGENT_TIME_WINDOW_SIZE_SCALE * AGENT_AVERAGE_STYLE_COEFFICIENT;
			MARKET_AGENT_AVERAGE_TIME_WINDOW_SIZE.put(market, AGENT_AVERAGE_TIME_WINDOW_SIZE);

			Console.OUT.println("# AGENTS IN SPOT MARKET (" + market.id + ")");
			Console.OUT.println("#   AGENTS_COUNT " + AGENTS_COUNT);
			Console.OUT.println("#   AGENT_ASSET_VOLUME_SCALE " + AGENT_ASSET_VOLUME_SCALE);
			Console.OUT.println("#   AGENT_CASH_AMOUNT_SCALE " + AGENT_CASH_AMOUNT_SCALE);
			Console.OUT.println("#   AGENT_SECONDARY_ASSETS_SCALE " + AGENT_SECONDARY_ASSETS_SCALE);
			Console.OUT.println("#   AGENT_SECONDARY_PROBABILITY " + AGENT_SECONDARY_PROBABILITY);
			Console.OUT.println("#   AGENT_FUNDAMENTAL_WEIGHT_SCALE " + AGENT_FUNDAMENTAL_WEIGHT_SCALE);
			Console.OUT.println("#   AGENT_CHART_WEIGHT_SCALE " + AGENT_CHART_WEIGHT_SCALE);
			Console.OUT.println("#   AGENT_NOISE_WEIGHT_SCALE " + AGENT_NOISE_WEIGHT_SCALE);
			Console.OUT.println("#   AGENT_CHART_FOLLOWERS_CHANCE " + AGENT_CHART_FOLLOWERS_CHANCE);
			Console.OUT.println("#   AGENT_TIME_WINDOW_SIZE_SCALE " + AGENT_TIME_WINDOW_SIZE_SCALE);
			Console.OUT.println("#   AGENT_AVERAGE_STYLE_COEFFICIENT " + AGENT_AVERAGE_STYLE_COEFFICIENT);
			Console.OUT.println("#   AGENT_AVERAGE_TIME_WINDOW_SIZE " + AGENT_AVERAGE_TIME_WINDOW_SIZE);

			for (i in 0..(AGENTS_COUNT - 1)) {
				val id = agents.size();
				val fundamentalWeight = nextExponential(random, AGENT_FUNDAMENTAL_WEIGHT_SCALE);
				val chartWeight = nextExponential(random, AGENT_CHART_WEIGHT_SCALE);
				val noiseWeight = nextExponential(random, AGENT_NOISE_WEIGHT_SCALE);
				val isChartFollowing = (random.nextDouble() < AGENT_CHART_FOLLOWERS_CHANCE);
				val agent = new CIP2009Agent(id, fundamentalWeight, chartWeight, noiseWeight);
				agent.setTimeWindowSize(AGENT_TIME_WINDOW_SIZE_SCALE);
				agent.setFundamentalMeanReversionTime(AGENT_FUNDAMENTAL_MEAN_REVERSION_TIME);
				val initialAssetVolume = random.nextLong(AGENT_ASSET_VOLUME_SCALE);
				agent.addPrimaryMarket(market, 1.0);
				agent.setAssetVolume(market, initialAssetVolume);
				agent.setChoosingSecondaryProbability(AGENT_SECONDARY_PROBABILITY);
				for (m in spotMarkets) {
					if (m != market) {
						agent.addSecondaryMarket(m, cor(m.id)(market.id));
						agent.setAssetVolume(m, ((initialAssetVolume * AGENT_SECONDARY_ASSETS_SCALE) / (SPOT_MARKETS_COUNT - 1)) as Long);
					}
				}
				val initialCashAmount = random.nextDouble() * AGENT_CASH_AMOUNT_SCALE;
				agent.setCashAmount(initialCashAmount);
				agents.add(agent);

				LARGEST_TIME_WINDOW_SIZE = Math.max(agent.timeWindowSize, LARGEST_TIME_WINDOW_SIZE);
			}
		}

		for (m in 0..(INDEX_MARKETS_COUNT - 1)) {
			// TODO
		}

		Console.OUT.println("# LARGEST_TIME_WINDOW_SIZE " + LARGEST_TIME_WINDOW_SIZE);
		Console.OUT.println("# MARKET_CLOSE_TIME " + (LARGEST_TIME_WINDOW_SIZE + MARKET_ITERATION));

		Market.TIME.set(1);

		// To fill with fundamental prices/returns, to initiate the trends.
		val MARKET_INITIATION = LARGEST_TIME_WINDOW_SIZE / 2;
		for (t in 1..MARKET_INITIATION) {
			// No trading; No circuit breaker; No market attack; No printing.
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
			
			//print(0, agents, markets, allOrders);

			Market.TIME.next();
		}

		val MARKET_TRANSIENT = LARGEST_TIME_WINDOW_SIZE / 2;
		for (t in 1..MARKET_TRANSIENT) {
			// No circuit breaker; No market attack.
			val allOrders = new ArrayList[Order]();

			if (MARKET_UPDATE == MARKET_UPDATE_ONE_AGENT_ONE_ORDER) {
				doOneAgentOneOrderUpdate(random, agents, markets, allOrders);
			}
			if (MARKET_UPDATE == MARKET_UPDATE_ONE_MARKET_ONE_ORDER) {
				doOneMarketOneOrderUpdate(random, agents, markets, allOrders);
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

			print(1, agents, markets, allOrders);

			Market.TIME.next();
		}

		assert opt.get("marketrule").size % 3 == 0 : "The option --marketrule must be 3-tuples";
		val marketRules = new ArrayList[MarketRule]();
		for (i in 0..(opt.get("marketrule").size / 3 - 1)) {
			val arg1 = opt.get("marketrule")(i * 3 + 0);
			val arg2 = opt.get("marketrule")(i * 3 + 1);
			val arg3 = opt.get("marketrule")(i * 3 + 2);
			val id = Long.parse(arg1);
			val basePrice = markets(id).getPrice(markets(id).getTime()); // MARKET_FUNDAMENTAL_PRICE;
			val changeRate = Double.parse(arg2);
			val AGENT_AVERAGE_TIME_WINDOW_SIZE = MARKET_AGENT_AVERAGE_TIME_WINDOW_SIZE.get(markets(id))();
			val timeLength = (AGENT_AVERAGE_TIME_WINDOW_SIZE * Double.parse(arg3)) as Long;
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
			marketAttacks.add(new MarketAttack(markets(id), markets(id).getTime() + time, priceImpact, volumeImpact));

			Console.OUT.println("# MARKET ATTACK (no." + i + ")");
			Console.OUT.println("#   market.id " + id);
			Console.OUT.println("#   time " + time);
			Console.OUT.println("#   priceImpact " + priceImpact);
			Console.OUT.println("#   volumeImpact " + volumeImpact);
		}
		
		for (t in 1..MARKET_ITERATION) {
			val allOrders = new ArrayList[Order]();

			if (MARKET_UPDATE == MARKET_UPDATE_ONE_AGENT_ONE_ORDER) {
				doOneAgentOneOrderUpdate(random, agents, markets, allOrders);
			}
			if (MARKET_UPDATE == MARKET_UPDATE_ONE_MARKET_ONE_ORDER) {
				doOneMarketOneOrderUpdate(random, agents, markets, allOrders);
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
			
			print(2, agents, markets, allOrders);
			if (true) {
				markets(1).buyOrderBook.dumpII();
				markets(1).sellOrderBook.dumpII();
			}
			
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

