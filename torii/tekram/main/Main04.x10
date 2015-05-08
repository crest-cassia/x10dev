package tekram.main;
import x10.io.File;
import x10.util.ArrayList;
import x10.util.HashMap;
import x10.util.HashSet;
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
import tekram.agent.ArbitrageAgent;
import tekram.agent.BidAskArbitrageAgent;
import tekram.agent.MiddleArbitrageAgent;
import tekram.agent.CIP2004;
import tekram.agent.CIP2009;
import tekram.agent.SingleAssetAgent;
import tekram.marketattack.FundamentalPriceAttack;
import tekram.marketattack.MarketAttack;
import tekram.marketattack.MarketPriceAttack;
import tekram.marketindex.CapitalWeightedIndex;
import tekram.marketindex.CapitalWeightedFundamentalIndex;
import tekram.marketrule.CircuitBreaker;
import tekram.marketrule.MarketRule;
import tekram.util.Cholesky;
import tekram.util.Gaussian;
import tekram.util.GeomBrownian;
import tekram.util.JSON;
import tekram.util.MultiGeomBrownian;
import tekram.util.RandomPermutation;

public class Main04 {

	public static def doArbitrageUpdate(MAX_INTRUSION_COUNT:Long, random:Random, agents:List[Agent], markets:List[IndexMarket], allOrders:List[Order]) {
		val blockedAgents = new HashSet[Agent]();
		val randomAgents = new RandomPermutation[Agent](random, agents);

		assert markets.size() == 1;
		for (market in markets) { // NOTE: markets <: IndexMarket
			if (!isArbitrageAvailable(market)) {
				continue;
			}
			randomAgents.shuffle();
			var k:Long = 0;
			for (agent in randomAgents) {
//				if (!isAgentWaitingAnyOrders(agent, markets)) {
					val orders = agent.placeOrders(market);
					if (orders.size() > 0) {
						for (order in orders) {
							order.getMarket().handleOrder(order);
							allOrders.add(order);
							blockedAgents.add(agent);
						}
						k++;
					}
//				}
				if (k >= MAX_INTRUSION_COUNT) {
					break; // Next market.
				}
			}
		}
	}

	/**
	 * ONE-AGENT ONE-ORDER (TO ONE-MARKET) RULE.
	 * Under this rule, no agent can submit more than one order; hence no arbitragers.
	 */
	public static def doOneAgentOneOrderUpdate(random:Random, agents:List[Agent], markets:List[Market], allOrders:List[Order]) {
		val blockedAgents = new HashSet[Agent]();
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
//				if (!isAgentWaitingAnyOrders(agent, markets)) {
					val orders = agent.placeOrders(market);
					if (orders.size() > 0) {
						assert orders.size() == 1;
						val order = orders(0);
						market.handleOrder(order);
						allOrders.add(order);
						blockedAgents.add(agent);
						break; // Next market.
					}
//				}
			}
		}
	}

	/**
	 * ONE-MARKET ONE-ORDER (SOME ORDERS BY ONE-AGENT) RULE.
	 * Under this rule, no markets can accept more than one order; hence no arbitragers.
	 */
	public static def doOneMarketOneOrderUpdate(random:Random, agents:List[Agent], markets:List[Market], allOrders:List[Order]) {
		val blockedMarkets = new HashSet[Market]();
		val randomMarkets = new RandomPermutation[Market](random, markets);
		val randomAgents = new RandomPermutation[Agent](random, agents);

		randomAgents.shuffle();
		for (agent in randomAgents) {
			if (blockedMarkets.size() == markets.size()) {
				break;
			}
//			if (!isAgentWaitingAnyOrders(agent, markets)) {
				val orders = agent.placeOrders(markets); // NOTE: In one of all markets.
				for (order in orders) {
					val market = order.getMarket();
					if (!blockedMarkets.contains(market)) {
						market.handleOrder(order);
						allOrders.add(order);
						blockedMarkets.add(market);
					}
				}
//			}
		}
	}

	/**
	 * http://en.wikipedia.org/wiki/Exponential_distribution
	 * http://en.wikipedia.org/wiki/Laplace_distribution
	 */
	public static def nextExponential(random:Random, lambda:Double) {
		return lambda * -Math.log(random.nextDouble());
	}

//	public static def isAgentWaitingAnyOrders[T](agent:Agent, markets:List[T]){T<:Market} {
//		for (market in markets) {
//			if (market.containsOrderOf(agent)) {
//				return true;
//			}
//		}
//		return false;
//	}

	public static def isArbitrageAvailable(market:IndexMarket):Boolean {
		val index = market;
		val spots = index.getMarkets();
		if (!index.isRunning()) {
			return false;
		}
		for (spot in spots) {
			if (!spot.isRunning()) {
				return false;
			}
		}
		return true;
	}

	public static def print(phaseCode:Long, agents:List[Agent], markets:List[Market], orders:List[Order]) {
		val t = Global.TIME.get();

		for (market in markets) {
			var marketIndex:Double = Double.NaN;
			var fundamentalIndex:Double = Double.NaN;
			if (market instanceof IndexMarket) {
				marketIndex = (market as IndexMarket).getMarketIndex();
				fundamentalIndex = (market as IndexMarket).getFundamentalIndex();
			}

			var localBuyOrdersCount:Long = 0;
			var localSellOrdersCount:Long = 0;
			var globalBuyOrdersCount:Long = 0;
			var globalSellOrdersCount:Long = 0;
			for (order in orders) {
				if (order.getMarket() == market) {
					if (order.getAgent() instanceof ArbitrageAgent) {
						if (order.isBuyOrder()) {
							globalBuyOrdersCount++;
						}
						if (order.isSellOrder()) {
							globalSellOrdersCount++;
						}

					} else {
						if (order.isBuyOrder()) {
							localBuyOrdersCount++;
						}
						if (order.isSellOrder()) {
							localSellOrdersCount++;
						}
					}
				}
			}

			Console.OUT.println(StringUtil.formatArray([
//				"DATA",
				phaseCode,
//				t, 
//				market.id,
				(market.isRunning() ? 1 : 0),
				market.getMarketPrice(t),
//				market.getMarketReturn(t),
				market.getFundamentalPrice(t),
//				market.getFundamentalReturn(t),
//				(market.getMarketPrice(t) - market.getMarketPrice(t - 1)),
				//
				marketIndex,
//				fundamentalIndex,
				//
//				market.buyOrdersCounts(t),
//				market.sellOrdersCounts(t),
//				market.executedOrdersCounts(t),
//				market.lastExecutedPrices(t),
				//
				market.getBuyOrderBook().getBestPrice(),
				market.getSellOrderBook().getBestPrice(),
//				market.getBuyOrderBook().size(),
//				market.getSellOrderBook().size(),
//				market.getBuyOrderBook().getTotalPrice(),
//				market.getSellOrderBook().getTotalPrice(),
//				market.getBuyOrderBook().getTotalVolume(),
//				market.getSellOrderBook().getTotalVolume(),
				//
				localBuyOrdersCount,
				localSellOrdersCount,
				globalBuyOrdersCount,
				globalSellOrdersCount,
				"", ""], " ", "", Int.MAX_VALUE));
		}
	}


	public static def main(args:Rail[String]) {
		if (args.size < 1) {
			throw new Exception("Usage: ./a.out config.json");
		}
		val configFile = args(0);
		val json = JSON.parse(new File(configFile));

		val SYSTEM_GC_EVERY_LOOP = json("gc-every-loop").toBoolean();

		val DUMP_ORDERBOOK = json("output")("orderbook").toBoolean();
		val DUMP_SYSTEMINFO = json("output")("system-info").toBoolean();

		val SPOT_MARKETS_COUNT = json("#spot-markets").toLong();
		val INDEX_MARKETS_COUNT = json("#index-markets").toLong();
		val MARKETS_COUNT = SPOT_MARKETS_COUNT + INDEX_MARKETS_COUNT;
		val MARKET_ITERATION = json("#iteration").toLong();
		val MARKET_UPDATE_ONE_AGENT_ONE_ORDER = 0x1;
		val MARKET_UPDATE_ONE_MARKET_ONE_ORDER = 0x2;
		val MARKET_UPDATE = MARKET_UPDATE_ONE_MARKET_ONE_ORDER;

		Console.OUT.println("# NO_ALTERNATIVE_SINGLE " + true);
		Console.OUT.println("# NO_ALTERNATIVE_ARBITRAGE " + true);
		Console.OUT.println("# SPOT_MARKETS_COUNT " + SPOT_MARKETS_COUNT);
		Console.OUT.println("# INDEX_MARKETS_COUNT " + INDEX_MARKETS_COUNT);
		Console.OUT.println("# MARKETS_COUNT " + MARKETS_COUNT);
		Console.OUT.println("# MARKET_ITERATION " + MARKET_ITERATION);
		Console.OUT.println("# MARKET_UPDATE " + MARKET_UPDATE);

		val s0 = new Rail[Double](SPOT_MARKETS_COUNT);
		for (i in 0..(SPOT_MARKETS_COUNT - 1)) {
			s0(i) = json("spot-markets")([i, "default"])("fundamental-initial-price").toDouble();
		}
		val mu = new Rail[Double](SPOT_MARKETS_COUNT);
		for (i in 0..(SPOT_MARKETS_COUNT - 1)) {
			mu(i) = json("spot-markets")([i, "default"])("fundamental-drift").toDouble();
		}
		val sigma = new Rail[Double](SPOT_MARKETS_COUNT);
		for (i in 0..(SPOT_MARKETS_COUNT - 1)) {
			sigma(i) = json("spot-markets")([i, "default"])("fundamental-volatility").toDouble();
		}
		val cor = new Rail[Rail[Double]](SPOT_MARKETS_COUNT);
		for (i in 0..(SPOT_MARKETS_COUNT - 1)) {
			cor(i) = new Rail[Double](SPOT_MARKETS_COUNT);
		}
		if (SPOT_MARKETS_COUNT == 1) {
			cor(0)(0) = 1.0;
		}
		if (SPOT_MARKETS_COUNT == 2) {
			val v = json("spot-markets")("fundamental-correlation");
			val a = v("a").toDouble();
			cor(0)(0) = 1.0; cor(0)(1) =  a ;
			cor(1)(0) =  a ; cor(1)(1) = 1.0;
		}
		if (SPOT_MARKETS_COUNT == 3) {
			val v = json("spot-markets")("fundamental-correlation");
			val a = v("a").toDouble();
			val b = v("b").toDouble();
			cor(0)(0) = 1.0; cor(0)(1) =  a ; cor(0)(2) =  b ;
			cor(1)(0) =  a ; cor(1)(1) = 1.0; cor(1)(2) =  b ;
			cor(2)(0) =  b ; cor(2)(1) =  b ; cor(2)(2) = 1.0;
		}
		if (SPOT_MARKETS_COUNT == 4) {
			val v = json("spot-markets")("fundamental-correlation");
			val a = v("a").toDouble();
			val b = v("b").toDouble();
			val c = v("c").toDouble();
			cor(0)(0) = 1.0; cor(0)(1) =  a ; cor(0)(2) =  c ; cor(0)(3) =  c ;
			cor(1)(0) =  a ; cor(1)(1) = 1.0; cor(1)(2) =  c ; cor(1)(3) =  c ;
			cor(2)(0) =  c ; cor(2)(1) =  c ; cor(2)(2) = 1.0; cor(2)(3) =  b ;
			cor(3)(0) =  c ; cor(3)(1) =  c ; cor(3)(2) =  b ; cor(3)(3) = 1.0;
		}
		if (SPOT_MARKETS_COUNT >= 5) {
			for (i in 0..(SPOT_MARKETS_COUNT - 1)) {
				cor(i)(i) = 1.0;
			}
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

		Global.TIME.set(1);

		val markets = new ArrayList[Market]();

		val spotMarkets = new ArrayList[Market]();
		for (i in 0..(SPOT_MARKETS_COUNT - 1)) {
			val id = markets.size();
			val market = new Market(id);
			val initialFundamental = json("spot-markets")([i, "default"])("fundamental-initial-price").toDouble();
			val initialPrice = json("spot-markets")([i, "default"])("initial-price").toDouble();
			val outstandingShares = json("spot-markets")([i, "default"])("outstanding-shares").toLong();
			market.setInitialMarketPrice(initialPrice);
			market.setInitialFundamentalPrice(initialFundamental);
			market.setOutstandingShares(outstandingShares);
			markets.add(market);
			spotMarkets.add(market);

			Console.OUT.println("# SPOT MARKET " + id);
			Console.OUT.println("#   initialMarketPrice " + initialPrice);
			Console.OUT.println("#   initialFundamentalPrice " + initialFundamental);
		}

		val indexMarkets = new ArrayList[IndexMarket]();
		for (i in 0..(INDEX_MARKETS_COUNT - 1)) {
			val id = markets.size();
			val market = new IndexMarket(id);
			for (spotMarket in spotMarkets) {
				market.addMarket(spotMarket);
			}
			// NOTE: Use the initial index price for normalizing.
			val marketIndex = new CapitalWeightedIndex();
			marketIndex.normal = marketIndex.getIndex(market.getMarkets());
			marketIndex.scale = json("index-markets")([i, "default"])("initial-price").toDouble();
			market.setMarketIndexMethod(marketIndex);
			// NOTE: Use the initial index price for normalizing.
			val fundamentalIndex = new CapitalWeightedFundamentalIndex();
			fundamentalIndex.normal = fundamentalIndex.getIndex(market.getMarkets());
			fundamentalIndex.scale = json("index-markets")([i, "default"])("fundamental-initial-price").toDouble();
			market.setFundamentalIndexMethod(fundamentalIndex);

			val initialFundamental = market.getFundamentalIndex();
			val initialPrice = market.getMarketIndex();
			val outstandingShares = json("index-markets")([i, "default"])("outstanding-shares").toLong();
			market.setInitialMarketPrice(initialPrice);
			market.setInitialFundamentalPrice(initialFundamental);
			market.setOutstandingShares(outstandingShares);
			markets.add(market);
			indexMarkets.add(market);

			Console.OUT.println("# INDEX MARKET " + id);
			Console.OUT.println("#   initialMarketPrice " + initialPrice);
			Console.OUT.println("#   initialFundamentalPrice " + initialFundamental);
		}

		var LARGEST_TIME_WINDOW_SIZE:Long = Long.MIN_VALUE;
		var SMALLEST_TIME_WINDOW_SIZE:Long = Long.MAX_VALUE;
		val MARKET_AGENT_AVERAGE_TIME_WINDOW_SIZE = new HashMap[Market,Double](); // FIXME: Ugly.

		val agents = new ArrayList[Agent]();
		val localAgents = new ArrayList[Agent]();
		val globalAgents = new ArrayList[Agent]();

		for (market in spotMarkets) {
			val v = json("spot-markets")([market.id, "default"]);
			val AGENTS_COUNT = v("#agents").toLong();
			val AGENT_ORDER_MAKING = v("agent")("order-making").toString();
			val AGENT_ASSET_VOLUME_SCALE = v("agent")("initial-asset-volume").toLong();
			val AGENT_CASH_AMOUNT_SCALE = v("agent")("initial-cash-amount").toDouble();
			//val AGENT_CASH_AMOUNT_SCALE = AGENT_ASSET_VOLUME_SCALE * MARKET_FUNDAMENTAL_PRICE;
			val AGENT_FUNDAMENTAL_WEIGHT_SCALE = 0.9; //v("agent")("fundamental-weight").toDouble();
			val AGENT_CHART_WEIGHT_SCALE = 0.0; //v("agent")("chart-weight").toDouble();
			val AGENT_NOISE_WEIGHT_SCALE = 0.9; //v("agent")("noise-weight").toDouble();
			val AGENT_CHART_FOLLOWERS_CHANCE = 1.0;
			val AGENT_TIME_WINDOW_SIZE_SCALE = v("agent")("time-window-size").toLong();
			val AGENT_TIME_WINDOW_SIZE_MIN = v("agent")("time-window-size-min").toLong();
			val AGENT_FUNDAMENTAL_MEAN_REVERSION_TIME = AGENT_TIME_WINDOW_SIZE_SCALE; // NOTE: No info in CIP (2009).
			val AGENT_NOISE_SCALE = v("agent")("noise-scale").toDouble();
			val AGENT_RISK_AVERSION_SCALE = v("agent")("risk-aversion").toDouble();
			val AGENT_MARGIN_WIDTH_SCALE = v("agent")("margin-width").toDouble();
			val AGENT_AVERAGE_STYLE_COEFFICIENT = (1.0 + AGENT_FUNDAMENTAL_WEIGHT_SCALE) / (1.0 + AGENT_CHART_WEIGHT_SCALE);
			val AGENT_AVERAGE_TIME_WINDOW_SIZE = AGENT_TIME_WINDOW_SIZE_SCALE * AGENT_AVERAGE_STYLE_COEFFICIENT;
			val AGENT_INFORMATION_DELAY = v("agent")("information-delay").toLong();
			MARKET_AGENT_AVERAGE_TIME_WINDOW_SIZE.put(market, AGENT_AVERAGE_TIME_WINDOW_SIZE);

			Console.OUT.println("# AGENTS IN SPOT MARKET (" + market.id + ")");
			Console.OUT.println("#   AGENTS_COUNT " + AGENTS_COUNT);
			Console.OUT.println("#   AGENT_ORDER_MAKING " + AGENT_ORDER_MAKING);
			Console.OUT.println("#   AGENT_ASSET_VOLUME_SCALE " + AGENT_ASSET_VOLUME_SCALE);
			Console.OUT.println("#   AGENT_CASH_AMOUNT_SCALE " + AGENT_CASH_AMOUNT_SCALE);
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
				var timeWindowSizeMax:Long = 0;

				val agent = new SingleAssetAgent(id);
				if (AGENT_ORDER_MAKING.equals("CIP2009")) {
					val cip2009 = new CIP2009(fundamentalWeight, chartWeight, noiseWeight);
					cip2009.timeWindowSizeScale = AGENT_TIME_WINDOW_SIZE_SCALE;
					cip2009.riskAversionScale = AGENT_RISK_AVERSION_SCALE; //0.1;
					cip2009.fundamentalMeanReversionTime = AGENT_FUNDAMENTAL_MEAN_REVERSION_TIME;
					cip2009.noiseScale = AGENT_NOISE_SCALE; //0.01; //0.0001;
					cip2009.timeWindowSizeMin = AGENT_TIME_WINDOW_SIZE_MIN;
					agent.orderMaking = cip2009;
					timeWindowSizeMax = Math.ceil(cip2009.timeWindowSizeScale * cip2009.styleCoefficient) as Long;
				} else if (AGENT_ORDER_MAKING.equals("CIP2004")) {
					val cip2004 = new CIP2004(fundamentalWeight, chartWeight, noiseWeight);
					cip2004.timeWindowSizeScale = 100;
					cip2004.marginWidth = random.nextDouble() * AGENT_MARGIN_WIDTH_SCALE;
					cip2004.fundamentalMeanReversionTime = AGENT_FUNDAMENTAL_MEAN_REVERSION_TIME;
					cip2004.noiseScale = AGENT_NOISE_SCALE; //0.01; //0.0001;
					cip2004.timeWindowSizeMin = AGENT_TIME_WINDOW_SIZE_MIN;
					cip2004.informationDelay = 0;
					agent.orderMaking = cip2004;
					timeWindowSizeMax = Math.ceil(cip2004.timeWindowSizeScale * cip2004.styleCoefficient) as Long;
				} else {
					// DIE!
				}

				agent.setPrimaryMarket(market);

				val initialAssetVolume = random.nextLong(AGENT_ASSET_VOLUME_SCALE);
				agent.setAssetVolume(market, initialAssetVolume);
				val initialCashAmount = random.nextDouble() * AGENT_CASH_AMOUNT_SCALE;
				agent.setCashAmount(initialCashAmount);
				agents.add(agent);
				localAgents.add(agent);

				LARGEST_TIME_WINDOW_SIZE = Math.max(timeWindowSizeMax, LARGEST_TIME_WINDOW_SIZE);
				SMALLEST_TIME_WINDOW_SIZE = Math.min(timeWindowSizeMax, SMALLEST_TIME_WINDOW_SIZE);
			}
		}

		for (market in indexMarkets) {
			val v = json("index-markets")([market.id, "default"]);
			val AGENTS_COUNT = v("#agents").toLong();
			val AGENT_ORDER_MAKING = v("agent")("order-making").toString();
			val AGENT_ASSET_VOLUME_SCALE = v("agent")("initial-asset-volume").toLong();
			val AGENT_CASH_AMOUNT_SCALE = v("agent")("initial-cash-amount").toDouble();
			//val AGENT_CASH_AMOUNT_SCALE = AGENT_ASSET_VOLUME_SCALE * MARKET_FUNDAMENTAL_PRICE;
			val AGENT_FUNDAMENTAL_WEIGHT_SCALE = 0.9; //v("agent")("fundamental-weight").toDouble();
			val AGENT_CHART_WEIGHT_SCALE = 0.0; //v("agent")("chart-weight").toDouble();
			val AGENT_NOISE_WEIGHT_SCALE = 0.9; //v("agent")("noise-weight").toDouble();
			val AGENT_CHART_FOLLOWERS_CHANCE = 1.0;
			val AGENT_TIME_WINDOW_SIZE_SCALE = v("agent")("time-window-size").toLong();
			val AGENT_TIME_WINDOW_SIZE_MIN = v("agent")("time-window-size-min").toLong();
			val AGENT_FUNDAMENTAL_MEAN_REVERSION_TIME = AGENT_TIME_WINDOW_SIZE_SCALE; // NOTE: No info in CIP (2009).
			val AGENT_NOISE_SCALE = v("agent")("noise-scale").toDouble();
			val AGENT_RISK_AVERSION_SCALE = v("agent")("risk-aversion").toDouble();
			val AGENT_MARGIN_WIDTH_SCALE = v("agent")("margin-width").toDouble();
			val AGENT_AVERAGE_STYLE_COEFFICIENT = (1.0 + AGENT_FUNDAMENTAL_WEIGHT_SCALE) / (1.0 + AGENT_CHART_WEIGHT_SCALE);
			val AGENT_AVERAGE_TIME_WINDOW_SIZE = AGENT_TIME_WINDOW_SIZE_SCALE * AGENT_AVERAGE_STYLE_COEFFICIENT;
			val AGENT_INFORMATION_DELAY = v("agent")("information-delay").toLong();
			MARKET_AGENT_AVERAGE_TIME_WINDOW_SIZE.put(market, AGENT_AVERAGE_TIME_WINDOW_SIZE);

			Console.OUT.println("# AGENTS IN INDEX MARKET (" + market.id + ")");
			Console.OUT.println("#   AGENTS_COUNT " + AGENTS_COUNT);
			Console.OUT.println("#   AGENT_ORDER_MAKING " + AGENT_ORDER_MAKING);
			Console.OUT.println("#   AGENT_ASSET_VOLUME_SCALE " + AGENT_ASSET_VOLUME_SCALE);
			Console.OUT.println("#   AGENT_CASH_AMOUNT_SCALE " + AGENT_CASH_AMOUNT_SCALE);
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
				var timeWindowSizeMax:Long = 0;

				val agent = new SingleAssetAgent(id);
				if (AGENT_ORDER_MAKING.equals("CIP2009")) {
					val cip2009 = new CIP2009(fundamentalWeight, chartWeight, noiseWeight);
					cip2009.timeWindowSizeScale = AGENT_TIME_WINDOW_SIZE_SCALE;
					cip2009.riskAversionScale = AGENT_RISK_AVERSION_SCALE; //0.1;
					cip2009.fundamentalMeanReversionTime = AGENT_FUNDAMENTAL_MEAN_REVERSION_TIME;
					cip2009.noiseScale = AGENT_NOISE_SCALE; //0.01; //0.0001;
					cip2009.timeWindowSizeMin = AGENT_TIME_WINDOW_SIZE_MIN;
					agent.orderMaking = cip2009;
					timeWindowSizeMax = Math.ceil(cip2009.timeWindowSizeScale * cip2009.styleCoefficient) as Long;
				} else if (AGENT_ORDER_MAKING.equals("CIP2004")) {
					val cip2004 = new CIP2004(fundamentalWeight, chartWeight, noiseWeight);
					cip2004.timeWindowSizeScale = AGENT_TIME_WINDOW_SIZE_SCALE;
					cip2004.marginWidth = random.nextDouble() * AGENT_MARGIN_WIDTH_SCALE;
					cip2004.fundamentalMeanReversionTime = AGENT_FUNDAMENTAL_MEAN_REVERSION_TIME;
					cip2004.noiseScale = AGENT_NOISE_SCALE; //0.01; //0.0001;
					cip2004.timeWindowSizeMin = AGENT_TIME_WINDOW_SIZE_MIN;
					cip2004.informationDelay = 0;
					agent.orderMaking = cip2004;
					timeWindowSizeMax = Math.ceil(cip2004.timeWindowSizeScale * cip2004.styleCoefficient) as Long;
				} else {
					// DIE!
				}

				agent.setPrimaryMarket(market);

				val initialAssetVolume = random.nextLong(AGENT_ASSET_VOLUME_SCALE);
				agent.setAssetVolume(market, initialAssetVolume);
				val initialCashAmount = random.nextDouble() * AGENT_CASH_AMOUNT_SCALE;
				agent.setCashAmount(initialCashAmount);
				agents.add(agent);
				localAgents.add(agent);

				LARGEST_TIME_WINDOW_SIZE = Math.max(timeWindowSizeMax, LARGEST_TIME_WINDOW_SIZE);
				SMALLEST_TIME_WINDOW_SIZE = Math.min(timeWindowSizeMax, SMALLEST_TIME_WINDOW_SIZE);
			}
		}

		Console.OUT.println("# LARGEST_TIME_WINDOW_SIZE " + LARGEST_TIME_WINDOW_SIZE);
		Console.OUT.println("# SMALLEST_TIME_WINDOW_SIZE " + SMALLEST_TIME_WINDOW_SIZE);
		Console.OUT.println("# MARKET_CLOSE_TIME " + (LARGEST_TIME_WINDOW_SIZE + MARKET_ITERATION));

		val ARBITRAGE_MAX_INTRUSION_COUNT = json("arbitrage-market")("max-intrusion-count").toLong();

		for (market in indexMarkets) {
			val v = json("arbitrage-market")([market.id, "default"]);
			val AGENTS_COUNT = v("#agents").toLong();
			val AGENT_ASSET_VOLUME_SCALE = v("agent")("initial-asset-volume").toLong();
			val AGENT_CASH_AMOUNT_SCALE = v("agent")("initial-cash-amount").toDouble();
			val AGENT_ORDER_MIN_VOLUME =  v("agent")("order-min-volume").toLong();
			val AGENT_ORDER_THRESHOLD_PRICE =  v("agent")("order-threshold-price").toDouble();
			val AGENT_ORDER_MAKING = v("agent")("order-making").toString();

			Console.OUT.println("# ARBITRAGE AGENTS IN INDEX MARKET (" + market.id + ")");
			Console.OUT.println("#   AGENTS_COUNT " + AGENTS_COUNT);
			Console.OUT.println("#   AGENT_ORDER_MAKING " + AGENT_ORDER_MAKING);
			Console.OUT.println("#   AGENT_ASSET_VOLUME_SCALE " + AGENT_ASSET_VOLUME_SCALE);
			Console.OUT.println("#   AGENT_CASH_AMOUNT_SCALE " + AGENT_CASH_AMOUNT_SCALE);
			Console.OUT.println("#   AGENT_ORDER_MIN_VOLUME " + AGENT_ORDER_MIN_VOLUME);
			Console.OUT.println("#   AGENT_ORDER_THRESHOLD_PRICE " + AGENT_ORDER_THRESHOLD_PRICE);

			for (i in 0..(AGENTS_COUNT - 1)) {
				val id = agents.size();
				var agent:ArbitrageAgent;
				if (AGENT_ORDER_MAKING.equals("BidAsk")) {
					val arb = new BidAskArbitrageAgent(id);
					arb.orderMinVolume = AGENT_ORDER_MIN_VOLUME;
					arb.orderThresholdPrice = AGENT_ORDER_THRESHOLD_PRICE;
					agent = arb;
				} else {
					val arb = new MiddleArbitrageAgent(id);
					arb.orderMinVolume = AGENT_ORDER_MIN_VOLUME;
					arb.orderThresholdPrice = AGENT_ORDER_THRESHOLD_PRICE;
					agent = arb;
				}
				agent.setMarketAccessible(market);
				for (m in market.getMarkets()) {
					agent.setMarketAccessible(m);
				}
				val initialAssetVolume = random.nextLong(AGENT_ASSET_VOLUME_SCALE);
				agent.setAssetVolume(market, initialAssetVolume);
				for (m in market.getMarkets()) {
					agent.setAssetVolume(m, initialAssetVolume);
				}
				val initialCashAmount = random.nextDouble() * AGENT_CASH_AMOUNT_SCALE * (1 + market.getMarkets().size());
				agent.setCashAmount(initialCashAmount);
				agents.add(agent);
				globalAgents.add(agent);
			}
		}

//		Global.TIME.set(1);

		// PHASE 0: INITIATION
		// PHASE 1: TRANSIENT (FREE RUN)
		// PHASE 2: SIMULATION

		for (market in markets) {
			market.setRunning(false);
		}

		// To fill with fundamental prices/returns, to initiate the trends.
		val MARKET_INITIATION = LARGEST_TIME_WINDOW_SIZE / 1;
		for (t in 1..MARKET_INITIATION) {
			// No trading; No circuit breaker; No market attack; No printing.
			fundamentals.nextBrownian();
			for (market in spotMarkets) {
				val nextFundamental = fundamentals.get(market.id);
				market.updateMarketPrice(nextFundamental);
				market.updateFundamentalPrice(nextFundamental);
				market.updateOrderBooks();
			}
			for (market in indexMarkets) {
				 // NOTE: The method getMarketIndex() has to be called
				 // after updaing the fundamental prices of all spot markets.
				val nextFundamental = market.getFundamentalIndex();
				market.updateMarketPrice(nextFundamental);
				market.updateFundamentalPrice(nextFundamental);
				market.updateOrderBooks();
			}
			
			Global.TIME.next();
			Global.STATISTICS.update();
		}

		// To fill order books with orders; no execution allowed.
		for (t in 1..MARKET_INITIATION) {
			val allOrders = new ArrayList[Order]();

//			if (indexMarkets.size() > 0) {
//				doArbitrageUpdate(ARBITRAGE_MAX_INTRUSION_COUNT, random, globalAgents, indexMarkets, allOrders);
//			}
			if (MARKET_UPDATE == MARKET_UPDATE_ONE_AGENT_ONE_ORDER) {
				doOneAgentOneOrderUpdate(random, localAgents, markets, allOrders);
			}
			if (MARKET_UPDATE == MARKET_UPDATE_ONE_MARKET_ONE_ORDER) {
				doOneMarketOneOrderUpdate(random, localAgents, markets, allOrders);
			}

			// No trading; No circuit breaker; No market attack; No printing.
			fundamentals.nextBrownian();
			for (market in spotMarkets) {
				val nextFundamental = fundamentals.get(market.id);
				market.updateMarketPrice(nextFundamental);
				market.updateFundamentalPrice(nextFundamental);
				market.updateOrderBooks();
			}
			for (market in indexMarkets) {
				 // NOTE: The method getMarketIndex() has to be called
				 // after updaing the fundamental prices of all spot markets.
				val nextFundamental = market.getFundamentalIndex();
				market.updateMarketPrice(nextFundamental);
				market.updateFundamentalPrice(nextFundamental);
				market.updateOrderBooks();
			}
			
			Global.TIME.next();
			Global.STATISTICS.update();
		}

		for (market in markets) {
			market.setRunning(true);
		}

		Console.OUT.println("# MARKET OPEN");

		for (t in 1..MARKET_INITIATION) {
			if (SYSTEM_GC_EVERY_LOOP) {
				System.gc();
			}

			var beginTime:Long = System.nanoTime();
			var endTime:Long;
			var heapSize:Long;

			val allOrders = new ArrayList[Order]();

//			if (indexMarkets.size() > 0) {
//				doArbitrageUpdate(ARBITRAGE_MAX_INTRUSION_COUNT, random, globalAgents, indexMarkets, allOrders);
//			}
			if (MARKET_UPDATE == MARKET_UPDATE_ONE_AGENT_ONE_ORDER) {
				doOneAgentOneOrderUpdate(random, localAgents, markets, allOrders);
			}
			if (MARKET_UPDATE == MARKET_UPDATE_ONE_MARKET_ONE_ORDER) {
				doOneMarketOneOrderUpdate(random, localAgents, markets, allOrders);
			}

			fundamentals.nextBrownian();
			for (market in spotMarkets) {
				val nextFundamental = fundamentals.get(market.id);
				market.updateMarketPrice();
				market.updateFundamentalPrice(nextFundamental);
				market.updateOrderBooks();
			}
			for (market in indexMarkets) {
				val nextFundamental = market.getFundamentalIndex();
				market.updateMarketPrice();
				market.updateFundamentalPrice(nextFundamental);
				market.updateOrderBooks();
			}
			
			print(0, agents, markets, allOrders);
			if (DUMP_ORDERBOOK) {
				for (market in markets) {
					market.buyOrderBook.dump();
					market.sellOrderBook.dump();
				}
			}

			endTime = System.nanoTime();
			heapSize = System.heapSize();
			if (DUMP_SYSTEMINFO) {
				Console.OUT.println(StringUtil.formatArray([
					"#SYSTEM", Global.TIME.get(), (endTime - beginTime), heapSize,
					"", ""], " ", "", Int.MAX_VALUE));
			}

			Global.TIME.next();
			Global.STATISTICS.update();
		}

		agents.clear();
		localAgents.clear();
		globalAgents.clear();

		for (market in spotMarkets) {
			val v = json("spot-markets")([market.id, "default"]);
			val AGENTS_COUNT = v("#agents").toLong();
			val AGENT_ORDER_MAKING = v("agent")("order-making").toString();
			val AGENT_ASSET_VOLUME_SCALE = v("agent")("initial-asset-volume").toLong();
			val AGENT_CASH_AMOUNT_SCALE = v("agent")("initial-cash-amount").toDouble();
			//val AGENT_CASH_AMOUNT_SCALE = AGENT_ASSET_VOLUME_SCALE * MARKET_FUNDAMENTAL_PRICE;
			val AGENT_FUNDAMENTAL_WEIGHT_SCALE = v("agent")("fundamental-weight").toDouble();
			val AGENT_CHART_WEIGHT_SCALE = v("agent")("chart-weight").toDouble();
			val AGENT_NOISE_WEIGHT_SCALE = v("agent")("noise-weight").toDouble();
			val AGENT_CHART_FOLLOWERS_CHANCE = 1.0;
			val AGENT_TIME_WINDOW_SIZE_SCALE = v("agent")("time-window-size").toLong();
			val AGENT_TIME_WINDOW_SIZE_MIN = v("agent")("time-window-size-min").toLong();
			val AGENT_FUNDAMENTAL_MEAN_REVERSION_TIME = AGENT_TIME_WINDOW_SIZE_SCALE; // NOTE: No info in CIP (2009).
			val AGENT_NOISE_SCALE = v("agent")("noise-scale").toDouble();
			val AGENT_RISK_AVERSION_SCALE = v("agent")("risk-aversion").toDouble();
			val AGENT_MARGIN_WIDTH_SCALE = v("agent")("margin-width").toDouble();
			val AGENT_AVERAGE_STYLE_COEFFICIENT = (1.0 + AGENT_FUNDAMENTAL_WEIGHT_SCALE) / (1.0 + AGENT_CHART_WEIGHT_SCALE);
			val AGENT_AVERAGE_TIME_WINDOW_SIZE = AGENT_TIME_WINDOW_SIZE_SCALE * AGENT_AVERAGE_STYLE_COEFFICIENT;
			val AGENT_INFORMATION_DELAY = v("agent")("information-delay").toLong();
			MARKET_AGENT_AVERAGE_TIME_WINDOW_SIZE.put(market, AGENT_AVERAGE_TIME_WINDOW_SIZE);

			Console.OUT.println("# AGENTS IN SPOT MARKET (" + market.id + ")");
			Console.OUT.println("#   AGENTS_COUNT " + AGENTS_COUNT);
			Console.OUT.println("#   AGENT_ORDER_MAKING " + AGENT_ORDER_MAKING);
			Console.OUT.println("#   AGENT_ASSET_VOLUME_SCALE " + AGENT_ASSET_VOLUME_SCALE);
			Console.OUT.println("#   AGENT_CASH_AMOUNT_SCALE " + AGENT_CASH_AMOUNT_SCALE);
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
				var timeWindowSizeMax:Long = 0;

				val agent = new SingleAssetAgent(id);
				if (AGENT_ORDER_MAKING.equals("CIP2009")) {
					val cip2009 = new CIP2009(fundamentalWeight, chartWeight, noiseWeight);
					cip2009.timeWindowSizeScale = AGENT_TIME_WINDOW_SIZE_SCALE;
					cip2009.riskAversionScale = AGENT_RISK_AVERSION_SCALE; //0.1;
					cip2009.fundamentalMeanReversionTime = AGENT_FUNDAMENTAL_MEAN_REVERSION_TIME;
					cip2009.noiseScale = AGENT_NOISE_SCALE; //0.01; //0.0001;
					cip2009.timeWindowSizeMin = AGENT_TIME_WINDOW_SIZE_MIN;
					agent.orderMaking = cip2009;
					timeWindowSizeMax = Math.ceil(cip2009.timeWindowSizeScale * cip2009.styleCoefficient) as Long;
				} else if (AGENT_ORDER_MAKING.equals("CIP2004")) {
					val cip2004 = new CIP2004(fundamentalWeight, chartWeight, noiseWeight);
					cip2004.timeWindowSizeScale = AGENT_TIME_WINDOW_SIZE_SCALE;
					cip2004.marginWidth = random.nextDouble() * AGENT_MARGIN_WIDTH_SCALE;
					cip2004.fundamentalMeanReversionTime = AGENT_FUNDAMENTAL_MEAN_REVERSION_TIME;
					cip2004.noiseScale = AGENT_NOISE_SCALE; //0.01; //0.0001;
					cip2004.timeWindowSizeMin = AGENT_TIME_WINDOW_SIZE_MIN;
					cip2004.informationDelay = nextExponential(random, AGENT_INFORMATION_DELAY) as Long;
					agent.orderMaking = cip2004;
					timeWindowSizeMax = Math.ceil(cip2004.timeWindowSizeScale * cip2004.styleCoefficient) as Long;
				} else {
					// DIE!
				}

				agent.setPrimaryMarket(market);

				val initialAssetVolume = random.nextLong(AGENT_ASSET_VOLUME_SCALE);
				agent.setAssetVolume(market, initialAssetVolume);
				val initialCashAmount = random.nextDouble() * AGENT_CASH_AMOUNT_SCALE;
				agent.setCashAmount(initialCashAmount);
				agents.add(agent);
				localAgents.add(agent);
			}
		}

		for (market in indexMarkets) {
			val v = json("index-markets")([market.id, "default"]);
			val AGENTS_COUNT = v("#agents").toLong();
			val AGENT_ORDER_MAKING = v("agent")("order-making").toString();
			val AGENT_ASSET_VOLUME_SCALE = v("agent")("initial-asset-volume").toLong();
			val AGENT_CASH_AMOUNT_SCALE = v("agent")("initial-cash-amount").toDouble();
			//val AGENT_CASH_AMOUNT_SCALE = AGENT_ASSET_VOLUME_SCALE * MARKET_FUNDAMENTAL_PRICE;
			val AGENT_FUNDAMENTAL_WEIGHT_SCALE = v("agent")("fundamental-weight").toDouble();
			val AGENT_CHART_WEIGHT_SCALE = v("agent")("chart-weight").toDouble();
			val AGENT_NOISE_WEIGHT_SCALE = v("agent")("noise-weight").toDouble();
			val AGENT_CHART_FOLLOWERS_CHANCE = 1.0;
			val AGENT_TIME_WINDOW_SIZE_SCALE = v("agent")("time-window-size").toLong();
			val AGENT_TIME_WINDOW_SIZE_MIN = v("agent")("time-window-size-min").toLong();
			val AGENT_FUNDAMENTAL_MEAN_REVERSION_TIME = AGENT_TIME_WINDOW_SIZE_SCALE; // NOTE: No info in CIP (2009).
			val AGENT_NOISE_SCALE = v("agent")("noise-scale").toDouble();
			val AGENT_RISK_AVERSION_SCALE = v("agent")("risk-aversion").toDouble();
			val AGENT_MARGIN_WIDTH_SCALE = v("agent")("margin-width").toDouble();
			val AGENT_AVERAGE_STYLE_COEFFICIENT = (1.0 + AGENT_FUNDAMENTAL_WEIGHT_SCALE) / (1.0 + AGENT_CHART_WEIGHT_SCALE);
			val AGENT_AVERAGE_TIME_WINDOW_SIZE = AGENT_TIME_WINDOW_SIZE_SCALE * AGENT_AVERAGE_STYLE_COEFFICIENT;
			val AGENT_INFORMATION_DELAY = v("agent")("information-delay").toLong();
			MARKET_AGENT_AVERAGE_TIME_WINDOW_SIZE.put(market, AGENT_AVERAGE_TIME_WINDOW_SIZE);

			Console.OUT.println("# AGENTS IN INDEX MARKET (" + market.id + ")");
			Console.OUT.println("#   AGENTS_COUNT " + AGENTS_COUNT);
			Console.OUT.println("#   AGENT_ORDER_MAKING " + AGENT_ORDER_MAKING);
			Console.OUT.println("#   AGENT_ASSET_VOLUME_SCALE " + AGENT_ASSET_VOLUME_SCALE);
			Console.OUT.println("#   AGENT_CASH_AMOUNT_SCALE " + AGENT_CASH_AMOUNT_SCALE);
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
				var timeWindowSizeMax:Long = 0;

				val agent = new SingleAssetAgent(id);
				if (AGENT_ORDER_MAKING.equals("CIP2009")) {
					val cip2009 = new CIP2009(fundamentalWeight, chartWeight, noiseWeight);
					cip2009.timeWindowSizeScale = AGENT_TIME_WINDOW_SIZE_SCALE;
					cip2009.riskAversionScale = AGENT_RISK_AVERSION_SCALE; //0.1;
					cip2009.fundamentalMeanReversionTime = AGENT_FUNDAMENTAL_MEAN_REVERSION_TIME;
					cip2009.noiseScale = AGENT_NOISE_SCALE; //0.01; //0.0001;
					cip2009.timeWindowSizeMin = AGENT_TIME_WINDOW_SIZE_MIN;
					agent.orderMaking = cip2009;
					timeWindowSizeMax = Math.ceil(cip2009.timeWindowSizeScale * cip2009.styleCoefficient) as Long;
				} else if (AGENT_ORDER_MAKING.equals("CIP2004")) {
					val cip2004 = new CIP2004(fundamentalWeight, chartWeight, noiseWeight);
					cip2004.timeWindowSizeScale = AGENT_TIME_WINDOW_SIZE_SCALE;
					cip2004.marginWidth = random.nextDouble() * AGENT_MARGIN_WIDTH_SCALE;
					cip2004.fundamentalMeanReversionTime = AGENT_FUNDAMENTAL_MEAN_REVERSION_TIME;
					cip2004.noiseScale = AGENT_NOISE_SCALE; //0.01; //0.0001;
					cip2004.timeWindowSizeMin = AGENT_TIME_WINDOW_SIZE_MIN;
					cip2004.informationDelay = nextExponential(random, AGENT_INFORMATION_DELAY) as Long;
					agent.orderMaking = cip2004;
					timeWindowSizeMax = Math.ceil(cip2004.timeWindowSizeScale * cip2004.styleCoefficient) as Long;
				} else {
					// DIE!
				}

				agent.setPrimaryMarket(market);

				val initialAssetVolume = random.nextLong(AGENT_ASSET_VOLUME_SCALE);
				agent.setAssetVolume(market, initialAssetVolume);
				val initialCashAmount = random.nextDouble() * AGENT_CASH_AMOUNT_SCALE;
				agent.setCashAmount(initialCashAmount);
				agents.add(agent);
				localAgents.add(agent);
			}
		}

		for (market in indexMarkets) {
			val v = json("arbitrage-market")([market.id, "default"]);
			val AGENTS_COUNT = v("#agents").toLong();
			val AGENT_ASSET_VOLUME_SCALE = v("agent")("initial-asset-volume").toLong();
			val AGENT_CASH_AMOUNT_SCALE = v("agent")("initial-cash-amount").toDouble();
			val AGENT_ORDER_MIN_VOLUME =  v("agent")("order-min-volume").toLong();
			val AGENT_ORDER_THRESHOLD_PRICE =  v("agent")("order-threshold-price").toDouble();
			val AGENT_ORDER_MAKING = v("agent")("order-making").toString();

			Console.OUT.println("# ARBITRAGE AGENTS IN INDEX MARKET (" + market.id + ")");
			Console.OUT.println("#   AGENTS_COUNT " + AGENTS_COUNT);
			Console.OUT.println("#   AGENT_ORDER_MAKING " + AGENT_ORDER_MAKING);
			Console.OUT.println("#   AGENT_ASSET_VOLUME_SCALE " + AGENT_ASSET_VOLUME_SCALE);
			Console.OUT.println("#   AGENT_CASH_AMOUNT_SCALE " + AGENT_CASH_AMOUNT_SCALE);
			Console.OUT.println("#   AGENT_ORDER_MIN_VOLUME " + AGENT_ORDER_MIN_VOLUME);
			Console.OUT.println("#   AGENT_ORDER_THRESHOLD_PRICE " + AGENT_ORDER_THRESHOLD_PRICE);

			for (i in 0..(AGENTS_COUNT - 1)) {
				val id = agents.size();
				var agent:ArbitrageAgent;
				if (AGENT_ORDER_MAKING.equals("BidAsk")) {
					val arb = new BidAskArbitrageAgent(id);
					arb.orderMinVolume = AGENT_ORDER_MIN_VOLUME;
					arb.orderThresholdPrice = AGENT_ORDER_THRESHOLD_PRICE;
					agent = arb;
				} else {
					val arb = new MiddleArbitrageAgent(id);
					arb.orderMinVolume = AGENT_ORDER_MIN_VOLUME;
					arb.orderThresholdPrice = AGENT_ORDER_THRESHOLD_PRICE;
					agent = arb;
				}
				agent.setMarketAccessible(market);
				for (m in market.getMarkets()) {
					agent.setMarketAccessible(m);
				}
				val initialAssetVolume = random.nextLong(AGENT_ASSET_VOLUME_SCALE);
				agent.setAssetVolume(market, initialAssetVolume);
				for (m in market.getMarkets()) {
					agent.setAssetVolume(m, initialAssetVolume);
				}
				val initialCashAmount = random.nextDouble() * AGENT_CASH_AMOUNT_SCALE * (1 + market.getMarkets().size());
				agent.setCashAmount(initialCashAmount);
				agents.add(agent);
				globalAgents.add(agent);
			}
		}

		val MARKET_TRANSIENT = LARGEST_TIME_WINDOW_SIZE / 1;
		for (t in 1..MARKET_TRANSIENT) {
			if (SYSTEM_GC_EVERY_LOOP) {
				System.gc();
			}

			var beginTime:Long = System.nanoTime();
			var endTime:Long;
			var heapSize:Long;

			// No circuit breaker; No market attack.
			val allOrders = new ArrayList[Order]();

			if (indexMarkets.size() > 0) {
				doArbitrageUpdate(ARBITRAGE_MAX_INTRUSION_COUNT, random, globalAgents, indexMarkets, allOrders);
			}
			if (MARKET_UPDATE == MARKET_UPDATE_ONE_AGENT_ONE_ORDER) {
				doOneAgentOneOrderUpdate(random, localAgents, markets, allOrders);
			}
			if (MARKET_UPDATE == MARKET_UPDATE_ONE_MARKET_ONE_ORDER) {
				doOneMarketOneOrderUpdate(random, localAgents, markets, allOrders);
			}
			
			fundamentals.nextBrownian();
			for (market in spotMarkets) {
				val nextFundamental = fundamentals.get(market.id);
				market.updateMarketPrice();
				market.updateFundamentalPrice(nextFundamental);
				market.updateOrderBooks();
			}
			for (market in indexMarkets) {
				val nextFundamental = market.getFundamentalIndex();
				market.updateMarketPrice();
				market.updateFundamentalPrice(nextFundamental);
				market.updateOrderBooks();
			}

			print(1, agents, markets, allOrders);
			if (DUMP_ORDERBOOK) {
				for (market in markets) {
					market.buyOrderBook.dump();
					market.sellOrderBook.dump();
				}
			}

			endTime = System.nanoTime();
			heapSize = System.heapSize();
			if (DUMP_SYSTEMINFO) {
				Console.OUT.println(StringUtil.formatArray([
					"#SYSTEM", Global.TIME.get(), (endTime - beginTime), heapSize,
					"", ""], " ", "", Int.MAX_VALUE));
			}

			Global.TIME.next();
			Global.STATISTICS.update();
		}

		val marketRules = new ArrayList[MarketRule]();
		for (i in 0..(json("market-rules").size() - 1)) {
			val v = json("market-rules")(i);
			if (!v("enabled").toBoolean()) {
				continue;
			}
			var market:Market;
			val id = v("target")("id").toLong();
			if (v("target")("class").toString().equals("index-market")) {
				market = indexMarkets(id);
			} else {
				market = spotMarkets(id);
			}
			val basePrice = market.getMarketPrice();
			val changeRate = v("change-rate").toDouble();
			val AGENT_AVERAGE_TIME_WINDOW_SIZE = MARKET_AGENT_AVERAGE_TIME_WINDOW_SIZE.get(market)();
			val timeLength = (AGENT_AVERAGE_TIME_WINDOW_SIZE * v("time-length").toDouble()) as Long;
			var activationCountMax:Long = Long.MAX_VALUE;
			if (v.has("activation-max")) {
				activationCountMax = v("activation-max").toLong();
			}
			val circuitBreaker = new CircuitBreaker(market, basePrice, changeRate, timeLength);
			circuitBreaker.setActivationCountMax(activationCountMax);
			for (j in 0..(v("followers").size() - 1)) {
				val follower = v("followers")(j)("id").toLong();
				if (v("followers")(j)("class").toString().equals("index-market")) {
					circuitBreaker.addCompanionMarket(indexMarkets(follower));
				} else {
					circuitBreaker.addCompanionMarket(spotMarkets(follower));
				}
			}
			marketRules.add(circuitBreaker);

			Console.OUT.println("# CIRCUIT BREAKER");
			Console.OUT.println("#   market.id " + market.id);
			Console.OUT.println("#   basePrice " + basePrice);
			Console.OUT.println("#   changeRate " + changeRate);
			Console.OUT.println("#   timeLength " + timeLength);
			Console.OUT.println("#   activationCountMax " + activationCountMax);
		}

		val marketAttacks = new ArrayList[MarketAttack]();
		for (i in 0..(json("market-attacks").size() - 1)) {
			val v = json("market-attacks")(i);
			if (!v("enabled").toBoolean()) {
				continue;
			}
			var market:Market;
			val id = v("target")("id").toLong();
			if (v("target")("class").toString().equals("index-market")) {
				market = indexMarkets(id);
			} else {
				market = spotMarkets(id);
			}
			if (v("class").toString().equals("FundamentalPriceAttack")) {
				val time = v("time").toLong();
				val priceImpact = v("price-impact").toDouble();
				marketAttacks.add(new FundamentalPriceAttack(fundamentals, market, Global.TIME.get() + time, priceImpact));

				Console.OUT.println("# FUNDAMENTAL PRICE ATTACK (no." + i + ")");
				Console.OUT.println("#   market.id " + market.id);
				Console.OUT.println("#   time " + (Global.TIME.get() + time));
				Console.OUT.println("#   priceImpact " + priceImpact);
			}
			if (v("class").toString().equals("MarketPriceAttack")) {
				val time = v("time").toLong();
				val priceImpact = v("price-impact").toDouble();
				val volumeImpact = v("volume-impact").toDouble();
				marketAttacks.add(new MarketPriceAttack(market, Global.TIME.get() + time, priceImpact, volumeImpact));

				Console.OUT.println("# MARKET PRICE ATTACK (no." + i + ")");
				Console.OUT.println("#   market.id " + market.id);
				Console.OUT.println("#   time " + (Global.TIME.get() + time));
				Console.OUT.println("#   priceImpact " + priceImpact);
				Console.OUT.println("#   volumeImpact " + volumeImpact);
			}
		}
		
		for (t in 1..MARKET_ITERATION) {
			if (SYSTEM_GC_EVERY_LOOP) {
				System.gc();
			}

			var beginTime:Long = System.nanoTime();
			var endTime:Long;
			var heapSize:Long;

			val allOrders = new ArrayList[Order]();

			if (indexMarkets.size() > 0) {
				doArbitrageUpdate(ARBITRAGE_MAX_INTRUSION_COUNT, random, globalAgents, indexMarkets, allOrders);
			}
			if (MARKET_UPDATE == MARKET_UPDATE_ONE_AGENT_ONE_ORDER) {
				doOneAgentOneOrderUpdate(random, localAgents, markets, allOrders);
			}
			if (MARKET_UPDATE == MARKET_UPDATE_ONE_MARKET_ONE_ORDER) {
				doOneMarketOneOrderUpdate(random, localAgents, markets, allOrders);
			}
			
			for (attack in marketAttacks) {
				attack.update();
			}

			fundamentals.nextBrownian();
			for (market in spotMarkets) {
				val nextFundamental = fundamentals.get(market.id);
				market.updateMarketPrice();
				market.updateFundamentalPrice(nextFundamental);
				market.updateOrderBooks();
			}
			for (market in indexMarkets) {
				val nextFundamental = market.getFundamentalIndex();
				market.updateMarketPrice();
				market.updateFundamentalPrice(nextFundamental);
				market.updateOrderBooks();
			}
			
			print(2, agents, markets, allOrders);
			if (DUMP_ORDERBOOK) {
				for (market in markets) {
					market.buyOrderBook.dump();
					market.sellOrderBook.dump();
				}
			}

			endTime = System.nanoTime();
			heapSize = System.heapSize();
			if (DUMP_SYSTEMINFO) {
				Console.OUT.println(StringUtil.formatArray([
					"#SYSTEM", Global.TIME.get(), (endTime - beginTime), heapSize,
					"", ""], " ", "", Int.MAX_VALUE));
			}

			for (rule in marketRules) {
				rule.update();
			}
			
			Global.TIME.next();
			Global.STATISTICS.update();
		}

		for (rule in marketRules) {
			val cbrule = rule as CircuitBreaker;
			Console.OUT.println("# #(circuit braker activated at " + cbrule.market.id + ") = " + cbrule.activationCount);
		}
	}
}

