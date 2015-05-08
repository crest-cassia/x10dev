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
import x10.util.concurrent.AtomicReference;
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

public class Main05 {


	public static def print(phaseCode:Long, agents:List[Agent], markets:List[Market], orders:List[Order]) {

		for (market in markets) {
			val t = market.getTime();
			var marketIndex:Double = Double.NaN;
			var fundamentalIndex:Double = Double.NaN;
			if (market instanceof IndexMarket) {
				marketIndex = (market as IndexMarket).getMarketIndex();
				fundamentalIndex = (market as IndexMarket).getFundamentalIndex();
			}

//			var localBuyOrdersCount:Long = 0;
//			var localSellOrdersCount:Long = 0;
//			var globalBuyOrdersCount:Long = 0;
//			var globalSellOrdersCount:Long = 0;
//			for (order in orders) {
//				if (order.getMarket() == market) {
//					if (order.getAgent() instanceof ArbitrageAgent) {
//						if (order.isBuyOrder()) {
//							globalBuyOrdersCount++;
//						}
//						if (order.isSellOrder()) {
//							globalSellOrdersCount++;
//						}
//					} else {
//						if (order.isBuyOrder()) {
//							localBuyOrdersCount++;
//						}
//						if (order.isSellOrder()) {
//							localSellOrdersCount++;
//						}
//					}
//				}
//			}

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
//				localBuyOrdersCount,
//				localSellOrdersCount,
//				globalBuyOrdersCount,
//				globalSellOrdersCount,
				"", ""], " ", "", Int.MAX_VALUE));
		}
	}


	/**
	 * http://en.wikipedia.org/wiki/Exponential_distribution
	 * http://en.wikipedia.org/wiki/Laplace_distribution
	 */
	public static def nextExponential(random:Random, lambda:Double):Double {
		return lambda * -Math.log(random.nextDouble());
	}


	public def doArbitrageUpdate(MAX_INTRUSION_COUNT:Long, agents:List[Agent], markets:List[IndexMarket], allOrders:List[Order]) {
		val random = RANDOM;

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
				val orders = agent.placeOrders(market);
				if (orders.size() > 0) {
					for (order in orders) {
						order.getMarket().handleOrder(order);
						allOrders.add(order);
						blockedAgents.add(agent);
					}
					k++;
				}
				if (k >= MAX_INTRUSION_COUNT) {
					break; // Next market.
				}
			}
		}
	}


	/**
	 * ONE-AGENT ONE-ORDER (TO ONE-MARKET) RULE.
	 * Under this rule, no agent can submit more than one order; hence no arbitrageurs.
	 */
	public def doOneAgentOneOrderUpdate(agents:List[Agent], markets:List[Market], allOrders:List[Order]) {
		val random = RANDOM;

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


	/**
	 * ONE-MARKET ONE-ORDER (SOME ORDERS BY ONE-AGENT) RULE.
	 * Under this rule, no markets can accept more than one order; hence no arbitrageurs.
	 */
	public def doOneMarketOneOrderUpdate(agents:List[Agent], markets:List[Market], allOrders:List[Order]) {
		val random = RANDOM;

		val blockedMarkets = new HashSet[Market]();
		val randomMarkets = new RandomPermutation[Market](random, markets);
		val randomAgents = new RandomPermutation[Agent](random, agents);

		randomAgents.shuffle();
		for (agent in randomAgents) {
			if (blockedMarkets.size() == markets.size()) {
				break;
			}
			val orders = agent.placeOrders(markets); // NOTE: In one of all markets.
			for (order in orders) {
				val market = order.getMarket();
				if (!blockedMarkets.contains(market)) {
					market.handleOrder(order);
					allOrders.add(order);
					blockedMarkets.add(market);
				}
			}
		}
	}


	//TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO 
	//TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO 
	public def collectOrdersByLocalAgents(agents:List[Agent], markets:List[Market]):List[List[Order]] {
//		val random = RANDOM;

		val allOrders = new ArrayList[List[Order]]();
		
//		val blockedMarkets = new HashSet[Market]();
//		val randomMarkets = new RandomPermutation[Market](random, markets);
//		val randomAgents = new RandomPermutation[Agent](random, agents);

		val X10_NTHREADS = System.getenv("X10_NTHREADS");
		var N_THREADS:Long;
		if (X10_NTHREADS == null) {
			N_THREADS = 1;
		} else {
			N_THREADS = Long.parse(X10_NTHREADS);
		}

		val SLEEP = 0;
		val MODE_ATOMIC = 0x1; // GOOD
		val MODE_KAMADA = 0x2; // VERY GOOD?
		val MODE_ATOMICREF = 0x3; // BAD!
		val MODE_RAILARRAY = 0x4; // BAD!
		val MODE = MODE_KAMADA;

		if (MODE == MODE_ATOMIC) {
			finish {
				for (agent in agents) {
					async {
						val orders = agent.placeOrders(markets); // NOTE: In one of all markets.
						atomic allOrders.add(orders);
						if (SLEEP > 0) System.threadSleep(SLEEP);
					}
				}
			}
		}
		if (MODE == MODE_KAMADA) {
			val N = agents.size();
			finish {
				for (t in 0..(N_THREADS - 1)) {
					async {
						val tempOrders = new ArrayList[List[Order]]();
						for (var i:Long = t; i < N; i += N_THREADS) {
							val agent = agents(i);
							val orders = agent.placeOrders(markets);
							tempOrders.add(orders);
							if (SLEEP > 0) System.threadSleep(SLEEP);
						}
						atomic allOrders.addAll(tempOrders);
					}
				}
			}
		}
//		if (MODE == MODE_ATOMICREF) {
//			val allOrdersRef = new AtomicReference[List[List[Order]]](allOrders);
//			finish {
//				randomAgents.shuffle();
//				for (agent in randomAgents) {
//					async {
//						val orders = agent.placeOrders(markets); // NOTE: In one of all markets.
//						allOrdersRef.get().add(orders);
//						if (SLEEP > 0) System.threadSleep(SLEEP);
//					}
//				}
//			}
//		}
//		if (MODE == MODE_RAILARRAY) {
//			val N = agents.size();
//			val temp = new Rail[List[Order]](N);
//			finish {
//				randomAgents.shuffle();
//				for (var i:Long = 0; i < N; i++) {
//					val k = i;
//					val agent = agents(k);
//					async {
//						val orders = agent.placeOrders(markets); // NOTE: In one of all markets.
//						temp(k) = orders;
//						if (SLEEP > 0) System.threadSleep(SLEEP);
//					}
//				}
//			}
//			for (var i:Long = 0; i < N; i++) {
//				allOrders.add(temp(i));
//			}
//		}
//		if (false) {
//			randomAgents.shuffle();
//			for (agent in randomAgents) {
//				if (blockedMarkets.size() == markets.size()) {
//					break;
//				}
//
//				val orders = agent.placeOrders(markets); // NOTE: In one of all markets.
//				allOrders.add(orders);
//
//				for (order in orders) {
//					val market = order.getMarket();
//					if (!blockedMarkets.contains(market)) {
//						//market.handleOrder(order); // NOTE: DON'T do it now.
//						blockedMarkets.add(market);
//					}
//				}
//			}
//		}

		return allOrders;
	}

	public def handleOrdersWithArbitrageurs(localOrders:List[List[Order]], MAX_INTRUSION_COUNT:Long, agents:List[Agent], markets:List[IndexMarket]):List[List[Order]] {
		val random = RANDOM;

		val allOrders = new ArrayList[List[Order]]();

		val randomAgents = new RandomPermutation[Agent](random, agents);
		val randomOrders = new RandomPermutation[List[Order]](random, localOrders);

		randomOrders.shuffle();
		for (someOrders in randomOrders) {
			// This handles one order-list submitted by an agent per loop.
			// TODO: If needed, one-market one-order handling.
			for (order in someOrders) {
				order.getMarket().handleOrder(order); // NOTE: DO it now.
			}

			assert markets.size() == 1;
			for (market in markets) { // NOTE: markets <: IndexMarket
				if (!isArbitrageAvailable(market)) {
					continue;
				}
				randomAgents.shuffle();
				val K = 5;//MAX_INTRUSION_COUNT; // TODO: Find better ones.
				var k:Long = 0;
				for (agent in randomAgents) {
					val orders = agent.placeOrders(market);
					allOrders.add(orders);

					if (orders.size() > 0) {
						for (order in orders) {
							order.getMarket().handleOrder(order);
						}
						k++;
					}
					if (k >= K) {
						break; // Next market.
					}
				}
			}
		}
		return allOrders;
	}
	//TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO 
	//TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO 


	public def isArbitrageAvailable(market:IndexMarket):Boolean {
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


	public def createMultiGeomBrownian(config:JSON.Value, N:Long):MultiGeomBrownian {
		val random = RANDOM;

		val s0 = new Rail[Double](N);
		for (i in 0..(N - 1)) {
			s0(i) = config("spot-markets")([i, "default"])("fundamental-initial-price").toDouble();
		}
		val mu = new Rail[Double](N);
		for (i in 0..(N - 1)) {
			mu(i) = config("spot-markets")([i, "default"])("fundamental-drift").toDouble();
		}
		val sigma = new Rail[Double](N);
		for (i in 0..(N - 1)) {
			sigma(i) = config("spot-markets")([i, "default"])("fundamental-volatility").toDouble();
		}
		val cor = new Rail[Rail[Double]](N);
		for (i in 0..(N - 1)) {
			cor(i) = new Rail[Double](N);
		}
		if (N == 1) {
			cor(0)(0) = 1.0;
		}
		if (N == 2) {
			val v = config("spot-markets")("fundamental-correlation");
			val a = v("a").toDouble();
			cor(0)(0) = 1.0; cor(0)(1) =  a ;
			cor(1)(0) =  a ; cor(1)(1) = 1.0;
		}
		if (N == 3) {
			val v = config("spot-markets")("fundamental-correlation");
			val a = v("a").toDouble();
			val b = v("b").toDouble();
			cor(0)(0) = 1.0; cor(0)(1) =  a ; cor(0)(2) =  b ;
			cor(1)(0) =  a ; cor(1)(1) = 1.0; cor(1)(2) =  b ;
			cor(2)(0) =  b ; cor(2)(1) =  b ; cor(2)(2) = 1.0;
		}
		if (N == 4) {
			val v = config("spot-markets")("fundamental-correlation");
			val a = v("a").toDouble();
			val b = v("b").toDouble();
			val c = v("c").toDouble();
			cor(0)(0) = 1.0; cor(0)(1) =  a ; cor(0)(2) =  c ; cor(0)(3) =  c ;
			cor(1)(0) =  a ; cor(1)(1) = 1.0; cor(1)(2) =  c ; cor(1)(3) =  c ;
			cor(2)(0) =  c ; cor(2)(1) =  c ; cor(2)(2) = 1.0; cor(2)(3) =  b ;
			cor(3)(0) =  c ; cor(3)(1) =  c ; cor(3)(2) =  b ; cor(3)(3) = 1.0;
		}
		if (N >= 5) {
			for (i in 0..(N - 1)) {
				cor(i)(i) = 1.0;
			}
		}

		Console.OUT.println("# GEOMETRIC BROWNIANS");
		Console.OUT.println("#   s0 " + s0);
		Console.OUT.println("#   mu " + mu);
		Console.OUT.println("#   sigma " + sigma);
		Console.OUT.println("#   cor " + cor);

		val chol = Cholesky.decompose(cor);
		val dt = 1.0;
		return new MultiGeomBrownian(random, mu, sigma, chol, s0, dt);
	}


	public def computeAverageTimeWindowSize(config:JSON.Value, market:Market, N:Long):Double {
		val FUNDAMENTAL_WEIGHT_SCALE = config("fundamental-weight").toDouble();
		val CHART_WEIGHT_SCALE = config("chart-weight").toDouble();
		val TIME_WINDOW_SIZE_SCALE = config("time-window-size").toLong();
		val AVERAGE_STYLE_COEFFICIENT = (1.0 + FUNDAMENTAL_WEIGHT_SCALE) / (1.0 + CHART_WEIGHT_SCALE);
		val AVERAGE_TIME_WINDOW_SIZE = TIME_WINDOW_SIZE_SCALE * AVERAGE_STYLE_COEFFICIENT;
		return AVERAGE_TIME_WINDOW_SIZE;
	}


	public def createLocalAgents(config:JSON.Value, market:Market, N:Long):List[Agent] {
		val random = RANDOM;

		val AGENTS_COUNT = N;
		val ORDER_MAKING = config("order-making").toString();
		val ASSET_VOLUME_SCALE = config("initial-asset-volume").toLong();
		val CASH_AMOUNT_SCALE = config("initial-cash-amount").toDouble();
		val FUNDAMENTAL_WEIGHT_SCALE = config("fundamental-weight").toDouble();
		val CHART_WEIGHT_SCALE = config("chart-weight").toDouble();
		val NOISE_WEIGHT_SCALE = config("noise-weight").toDouble();
		val CHART_FOLLOWERS_CHANCE = 1.0;
		val TIME_WINDOW_SIZE_SCALE = config("time-window-size").toLong();
		val TIME_WINDOW_SIZE_MIN = config("time-window-size-min").toLong();
		val FUNDAMENTAL_MEAN_REVERSION_TIME = TIME_WINDOW_SIZE_SCALE; // NOTE: No info in CIP (2009).
		val NOISE_SCALE = config("noise-scale").toDouble();
		val RISK_AVERSION_SCALE = config("risk-aversion").toDouble();
		val MARGIN_WIDTH_SCALE = config("margin-width").toDouble();
		val AVERAGE_STYLE_COEFFICIENT = (1.0 + FUNDAMENTAL_WEIGHT_SCALE) / (1.0 + CHART_WEIGHT_SCALE);
		val AVERAGE_TIME_WINDOW_SIZE = TIME_WINDOW_SIZE_SCALE * AVERAGE_STYLE_COEFFICIENT;
		val INFORMATION_DELAY = config("information-delay").toLong();

		Console.OUT.println("# AGENTS IN MARKET " + market.id);
		Console.OUT.println("#   AGENTS_COUNT " + AGENTS_COUNT);
		Console.OUT.println("#   ORDER_MAKING " + ORDER_MAKING);
		Console.OUT.println("#   ASSET_VOLUME_SCALE " + ASSET_VOLUME_SCALE);
		Console.OUT.println("#   CASH_AMOUNT_SCALE " + CASH_AMOUNT_SCALE);
		Console.OUT.println("#   FUNDAMENTAL_WEIGHT_SCALE " + FUNDAMENTAL_WEIGHT_SCALE);
		Console.OUT.println("#   CHART_WEIGHT_SCALE " + CHART_WEIGHT_SCALE);
		Console.OUT.println("#   NOISE_WEIGHT_SCALE " + NOISE_WEIGHT_SCALE);
		Console.OUT.println("#   CHART_FOLLOWERS_CHANCE " + CHART_FOLLOWERS_CHANCE);
		Console.OUT.println("#   TIME_WINDOW_SIZE_SCALE " + TIME_WINDOW_SIZE_SCALE);
		Console.OUT.println("#   AVERAGE_STYLE_COEFFICIENT " + AVERAGE_STYLE_COEFFICIENT);
		Console.OUT.println("#   AVERAGE_TIME_WINDOW_SIZE " + AVERAGE_TIME_WINDOW_SIZE);

		val agents = new ArrayList[Agent]();

		for (i in 0..(AGENTS_COUNT - 1)) {
			val id = agents.size();
			val fundamentalWeight = nextExponential(random, FUNDAMENTAL_WEIGHT_SCALE);
			val chartWeight = nextExponential(random, CHART_WEIGHT_SCALE);
			val noiseWeight = nextExponential(random, NOISE_WEIGHT_SCALE);
			val isChartFollowing = (random.nextDouble() < CHART_FOLLOWERS_CHANCE);

			if (ORDER_MAKING.equals("CIP2009")) {
				val agent = new SingleAssetAgent(id);
				agent.setPrimaryMarket(market);

				val initialAssetVolume = random.nextLong(ASSET_VOLUME_SCALE);
				agent.setAssetVolume(market, initialAssetVolume);
				val initialCashAmount = random.nextDouble() * CASH_AMOUNT_SCALE;
				agent.setCashAmount(initialCashAmount);

				val cip2009 = new CIP2009(fundamentalWeight, chartWeight, noiseWeight);
				cip2009.timeWindowSizeScale = TIME_WINDOW_SIZE_SCALE;
				cip2009.riskAversionScale = RISK_AVERSION_SCALE;
				cip2009.fundamentalMeanReversionTime = FUNDAMENTAL_MEAN_REVERSION_TIME;
				cip2009.noiseScale = NOISE_SCALE;
				cip2009.timeWindowSizeMin = TIME_WINDOW_SIZE_MIN;
				agent.orderMaking = cip2009;

				agents.add(agent);

			} else if (ORDER_MAKING.equals("CIP2004")) {
				val agent = new SingleAssetAgent(id);
				agent.setPrimaryMarket(market);

				val initialAssetVolume = random.nextLong(ASSET_VOLUME_SCALE);
				agent.setAssetVolume(market, initialAssetVolume);
				val initialCashAmount = random.nextDouble() * CASH_AMOUNT_SCALE;
				agent.setCashAmount(initialCashAmount);

				val cip2004 = new CIP2004(fundamentalWeight, chartWeight, noiseWeight);
				cip2004.timeWindowSizeScale = TIME_WINDOW_SIZE_SCALE;
				cip2004.marginWidth = random.nextDouble() * MARGIN_WIDTH_SCALE;
				cip2004.fundamentalMeanReversionTime = FUNDAMENTAL_MEAN_REVERSION_TIME;
				cip2004.noiseScale = NOISE_SCALE;
				cip2004.timeWindowSizeMin = TIME_WINDOW_SIZE_MIN;
				cip2004.informationDelay = nextExponential(random, INFORMATION_DELAY) as Long;
				agent.orderMaking = cip2004;

				agents.add(agent);

			} else {
				val agent = new Agent(id);
				agent.setMarketAccessible(market);
				agents.add(agent);
			}

		}
		return agents;
	}


	public def createArbitrageAgents(config:JSON.Value, market:IndexMarket, N:Long):List[Agent] {
		val random = RANDOM;

		val AGENTS_COUNT = N;
		val ASSET_VOLUME_SCALE = config("initial-asset-volume").toLong();
		val CASH_AMOUNT_SCALE = config("initial-cash-amount").toDouble();
		val ORDER_MIN_VOLUME =  config("order-min-volume").toLong();
		val ORDER_THRESHOLD_PRICE =  config("order-threshold-price").toDouble();
		val ORDER_MAKING = config("order-making").toString();

		Console.OUT.println("# ARBITRAGE AGENTS IN INDEX MARKET (" + market.id + ")");
		Console.OUT.println("#   AGENTS_COUNT " + AGENTS_COUNT);
		Console.OUT.println("#   ORDER_MAKING " + ORDER_MAKING);
		Console.OUT.println("#   ASSET_VOLUME_SCALE " + ASSET_VOLUME_SCALE);
		Console.OUT.println("#   CASH_AMOUNT_SCALE " + CASH_AMOUNT_SCALE);
		Console.OUT.println("#   ORDER_MIN_VOLUME " + ORDER_MIN_VOLUME);
		Console.OUT.println("#   ORDER_THRESHOLD_PRICE " + ORDER_THRESHOLD_PRICE);

		val agents = new ArrayList[Agent]();

		for (i in 0..(AGENTS_COUNT - 1)) {
			val id = agents.size();
			var agent:ArbitrageAgent;
			if (ORDER_MAKING.equals("BidAsk")) {
				val arb = new BidAskArbitrageAgent(id);
				arb.orderMinVolume = ORDER_MIN_VOLUME;
				arb.orderThresholdPrice = ORDER_THRESHOLD_PRICE;
				agent = arb;
			} else {
				val arb = new MiddleArbitrageAgent(id);
				arb.orderMinVolume = ORDER_MIN_VOLUME;
				arb.orderThresholdPrice = ORDER_THRESHOLD_PRICE;
				agent = arb;
			}
			agent.setMarketAccessible(market);
			for (m in market.getMarkets()) {
				agent.setMarketAccessible(m);
			}
			val initialAssetVolume = random.nextLong(ASSET_VOLUME_SCALE);
			agent.setAssetVolume(market, initialAssetVolume);
			for (m in market.getMarkets()) {
				agent.setAssetVolume(m, initialAssetVolume);
			}
			val initialCashAmount = random.nextDouble() * CASH_AMOUNT_SCALE * (1 + market.getMarkets().size());
			agent.setCashAmount(initialCashAmount);
			agents.add(agent);
		}
		return agents;
	}


	public var RANDOM:Random;
	public var CONFIG:JSON.Value;


	public def run(args:Rail[String]) {
		if (args.size < 1) {
			throw new Exception("Usage: ./a.out config.json");
		}

		val TIME_THE_BEGINNING = System.nanoTime();

		RANDOM = new Random();
		CONFIG = JSON.parse(new File(args(0)));

		val random = RANDOM;
		val config = CONFIG;


		val TIME_CONFIGURE_BEGIN = System.nanoTime();

		val SYSTEM_GC_EVERY_LOOP = config("gc-every-loop").toBoolean();
		val DUMP_ORDERBOOK = config("output")("orderbook").toBoolean();
		val DUMP_SYSTEMINFO = config("output")("system-info").toBoolean();

		val SPOT_MARKETS_COUNT = config("#spot-markets").toLong();
		val INDEX_MARKETS_COUNT = config("#index-markets").toLong();
		val MARKETS_COUNT = SPOT_MARKETS_COUNT + INDEX_MARKETS_COUNT;

		val MARKET_ITERATION = config("simulation-steps").toLong();
		val MARKET_UPDATE_ONE_AGENT_ONE_ORDER = 0x1;
		val MARKET_UPDATE_ONE_MARKET_ONE_ORDER = 0x2;
		val MARKET_UPDATE_ASYNC_BATCH_ORDER = 0x3;
		val MARKET_UPDATE = MARKET_UPDATE_ONE_MARKET_ONE_ORDER;
		val MINIMUM_INITIATION_STEPS = config("initiation-steps").toLong();
		val MINIMUM_TRANSIENT_STEPS = config("transient-steps").toLong();

		Console.OUT.println("# X10_NPLACES " + String.valueOf(System.getenv("X10_NPLACES")));
		Console.OUT.println("# X10_NTHREADS " + String.valueOf(System.getenv("X10_NTHREADS")));

		Console.OUT.println("# NO_ALTERNATIVE_SINGLE " + true);
		Console.OUT.println("# NO_ALTERNATIVE_ARBITRAGE " + true);
		Console.OUT.println("# SPOT_MARKETS_COUNT " + SPOT_MARKETS_COUNT);
		Console.OUT.println("# INDEX_MARKETS_COUNT " + INDEX_MARKETS_COUNT);
		Console.OUT.println("# MARKETS_COUNT " + MARKETS_COUNT);
		Console.OUT.println("# MARKET_ITERATION " + MARKET_ITERATION);
		Console.OUT.println("# MARKET_UPDATE " + MARKET_UPDATE);


		//////// MULTIVARIATE GEOMETRIC BROWNIAN ////////

		val fundamentals = createMultiGeomBrownian(config, SPOT_MARKETS_COUNT);
		fundamentals.nextBrownian();


		//////// MARKETS INSTANTIATION ////////

		val markets = new ArrayList[Market]();

		val spotMarkets = new ArrayList[Market]();
		for (i in 0..(SPOT_MARKETS_COUNT - 1)) {
			val id = markets.size();
			val market = new Market(id);
			markets.add(market);
			spotMarkets.add(market);
		}

		val indexMarkets = new ArrayList[IndexMarket]();
		for (i in 0..(INDEX_MARKETS_COUNT - 1)) {
			val id = markets.size();
			val market = new IndexMarket(id);
			markets.add(market);
			indexMarkets.add(market);
		}


		//////// MARKETS INITIALIZATION ////////

		for (market in spotMarkets) {
			val v = config("spot-markets")([market.id, "default"]);
			val initialFundamental = v("fundamental-initial-price").toDouble();
			val initialPrice = v("initial-price").toDouble();
			val outstandingShares = v("outstanding-shares").toLong();
			market.setInitialMarketPrice(initialPrice);
			market.setInitialFundamentalPrice(initialFundamental);
			market.setOutstandingShares(outstandingShares);

			market.updateTime();

			Console.OUT.println("# SPOT MARKET " + market.id);
			Console.OUT.println("#   initialMarketPrice " + initialPrice);
			Console.OUT.println("#   initialFundamentalPrice " + initialFundamental);
		}

		for (market in indexMarkets) {
			val v = config("index-markets")([market.id, "default"]);
			for (spotMarket in spotMarkets) {
				market.addMarket(spotMarket);
			}
			// NOTE: Use the initial index price for normalizing.
			val marketIndex = new CapitalWeightedIndex();
			marketIndex.normal = marketIndex.getIndex(market.getMarkets());
			marketIndex.scale = v("initial-price").toDouble();
			market.setMarketIndexMethod(marketIndex);

			// NOTE: Use the initial index price for normalizing.
			val fundamentalIndex = new CapitalWeightedFundamentalIndex();
			fundamentalIndex.normal = fundamentalIndex.getIndex(market.getMarkets());
			fundamentalIndex.scale = v("fundamental-initial-price").toDouble();
			market.setFundamentalIndexMethod(fundamentalIndex);

			val initialFundamental = market.getFundamentalIndex();
			val initialPrice = market.getMarketIndex();
			val outstandingShares = v("outstanding-shares").toLong();
			market.setInitialMarketPrice(initialPrice);
			market.setInitialFundamentalPrice(initialFundamental);
			market.setOutstandingShares(outstandingShares);

			market.updateTime();

			Console.OUT.println("# INDEX MARKET " + market.id);
			Console.OUT.println("#   initialMarketPrice " + initialPrice);
			Console.OUT.println("#   initialFundamentalPrice " + initialFundamental);
		}


		//////// SIMULATION WITHIN THREE PHASES ////////
		// SETUP AGENTS FOR INITIATION
		// PHASE 0: INITIATION ... dummy historical data with `init-agent` parameters
		// SETUP AGENTS FOR SIMULATION
		// PHASE 1: TRANSIENT  ... free run with `agent` parameters
		// PHASE 2: SIMULATION ... actual run with `agent` parameters
		////////////////////////////////////////////////


		//////// AGENTS INSTANTIATION & INITIALIZATION ////////

		val agents = new ArrayList[Agent]();
		val localAgents = new ArrayList[Agent]();
		val globalAgents = new ArrayList[Agent]();

		for (market in spotMarkets) {
			val i = market.id;
			val v = config("spot-markets")([i, "default"]);
			val N = v("#init-agents").toLong();
			val a = createLocalAgents(v("init-agent"), market, N);
			agents.addAll(a);
			localAgents.addAll(a);
		}

		for (market in indexMarkets) {
			val i = market.id - SPOT_MARKETS_COUNT;
			val v = config("index-markets")([i, "default"]);
			val N = v("#init-agents").toLong();
			val a = createLocalAgents(v("init-agent"), market, N);
			agents.addAll(a);
			localAgents.addAll(a);
		}

		for (market in indexMarkets) {
			val v = config("arbitrage-market")("default");
			val N = v("#init-agents").toLong();
			val a = createArbitrageAgents(v("init-agent"), market, N);
			agents.addAll(a);
			globalAgents.addAll(a);
		}


		//////// THEORETICAL TIME WINDOW SIZES ////////

		var LARGEST_TIME_WINDOW_SIZE:Long = Long.MIN_VALUE;
		val AVERAGE_TIME_WINDOW_SIZES = new HashMap[Market,Double](); // FIXME: Ugly.
		for (market in spotMarkets) {
			val i = market.id;
			val v = config("spot-markets")([i, "default"]);
			val N = v("#init-agents").toLong();
			val windowSize = computeAverageTimeWindowSize(v("init-agent"), market, N);
			AVERAGE_TIME_WINDOW_SIZES.put(market, windowSize);
			LARGEST_TIME_WINDOW_SIZE = Math.max(LARGEST_TIME_WINDOW_SIZE, windowSize as Long);
		}
		for (market in indexMarkets) {
			val i = market.id - SPOT_MARKETS_COUNT;
			val v = config("index-markets")([i, "default"]);
			val N = v("#init-agents").toLong();
			val windowSize = computeAverageTimeWindowSize(v("init-agent"), market, N);
			AVERAGE_TIME_WINDOW_SIZES.put(market, windowSize);
			LARGEST_TIME_WINDOW_SIZE = Math.max(LARGEST_TIME_WINDOW_SIZE, windowSize as Long);
		}

		Console.OUT.println("# LARGEST_TIME_WINDOW_SIZE " + LARGEST_TIME_WINDOW_SIZE);

		val TIME_CONFIGURE_END = System.nanoTime();


		/////////////////////////////////////
		//////// PHASE 0: INITIATION ////////
		/////////////////////////////////////

		for (market in markets) {
			market.setRunning(false);
		}

		// To fill with fundamental prices/returns, to initiate the trends.
		// No trading; No circuit breaker; No market attack; No printing.
		val MARKET_INITIATION = Math.max(LARGEST_TIME_WINDOW_SIZE, MINIMUM_INITIATION_STEPS) / 1;
		for (t in 1..MARKET_INITIATION) {
			fundamentals.nextBrownian();
			for (market in spotMarkets) {
				val nextFundamental = fundamentals.get(market.id);
				market.updateMarketPrice(nextFundamental);
				market.updateFundamentalPrice(nextFundamental);
				market.updateOrderBooks();
				market.updateTime();
			}
			for (market in indexMarkets) {
				 // NOTE: The method getMarketIndex() has to be called
				 // after updaing the fundamental prices of all spot markets.
				val nextFundamental = market.getFundamentalIndex();
				market.updateMarketPrice(nextFundamental);
				market.updateFundamentalPrice(nextFundamental);
				market.updateOrderBooks();
				market.updateTime();
			}
		}

		// To fill order books with orders; no execution allowed.
		for (t in 1..MARKET_INITIATION) {
			val allOrders = new ArrayList[Order]();

			if (MARKET_UPDATE == MARKET_UPDATE_ONE_AGENT_ONE_ORDER) {
				//if (indexMarkets.size() > 0) {
				//	doArbitrageUpdate(ARBITRAGE_MAX_INTRUSION_COUNT, globalAgents, indexMarkets, allOrders);
				//}
				doOneAgentOneOrderUpdate(localAgents, markets, allOrders);
			}
			if (MARKET_UPDATE == MARKET_UPDATE_ONE_MARKET_ONE_ORDER) {
				//if (indexMarkets.size() > 0) {
				//	doArbitrageUpdate(ARBITRAGE_MAX_INTRUSION_COUNT, globalAgents, indexMarkets, allOrders);
				//}
				doOneMarketOneOrderUpdate(localAgents, markets, allOrders);
			}
			if (MARKET_UPDATE == MARKET_UPDATE_ASYNC_BATCH_ORDER) {
				val ARBITRAGE_MAX_INTRUSION_COUNT = 0;
				val localOrders = collectOrdersByLocalAgents(localAgents, markets);
				val globalOrders = handleOrdersWithArbitrageurs(localOrders, ARBITRAGE_MAX_INTRUSION_COUNT, globalAgents, indexMarkets);
				for (orders in localOrders) {
					allOrders.addAll(orders);
				}
				for (orders in globalOrders) {
					allOrders.addAll(orders);
				}
			}

			// No trading; No circuit breaker; No market attack; No printing.
			fundamentals.nextBrownian();
			for (market in spotMarkets) {
				val nextFundamental = fundamentals.get(market.id);
				market.updateMarketPrice(nextFundamental);
				market.updateFundamentalPrice(nextFundamental);
				market.updateOrderBooks();
				market.updateTime();
			}
			for (market in indexMarkets) {
				val nextFundamental = market.getFundamentalIndex();
				market.updateMarketPrice(nextFundamental);
				market.updateFundamentalPrice(nextFundamental);
				market.updateOrderBooks();
				market.updateTime();
			}
		}

		for (market in markets) {
			market.setRunning(true);
		}

		for (t in 1..MARKET_INITIATION) {
			if (SYSTEM_GC_EVERY_LOOP) {
				System.gc();
			}

			var beginTime:Long = System.nanoTime();
			var endTime:Long;
			var heapSize:Long;

			val allOrders = new ArrayList[Order]();

			if (MARKET_UPDATE == MARKET_UPDATE_ONE_AGENT_ONE_ORDER) {
				//if (indexMarkets.size() > 0) {
				//	doArbitrageUpdate(ARBITRAGE_MAX_INTRUSION_COUNT, globalAgents, indexMarkets, allOrders);
				//}
				doOneAgentOneOrderUpdate(localAgents, markets, allOrders);
			}
			if (MARKET_UPDATE == MARKET_UPDATE_ONE_MARKET_ONE_ORDER) {
				//if (indexMarkets.size() > 0) {
				//	doArbitrageUpdate(ARBITRAGE_MAX_INTRUSION_COUNT, globalAgents, indexMarkets, allOrders);
				//}
				doOneMarketOneOrderUpdate(localAgents, markets, allOrders);
			}
			if (MARKET_UPDATE == MARKET_UPDATE_ASYNC_BATCH_ORDER) {
				val ARBITRAGE_MAX_INTRUSION_COUNT = 0;
				val localOrders = collectOrdersByLocalAgents(localAgents, markets);
				val globalOrders = handleOrdersWithArbitrageurs(localOrders, ARBITRAGE_MAX_INTRUSION_COUNT, globalAgents, indexMarkets);
				for (orders in localOrders) {
					allOrders.addAll(orders);
				}
				for (orders in globalOrders) {
					allOrders.addAll(orders);
				}
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
			
			val phaseCode = 0;
			print(phaseCode, agents, markets, allOrders);
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
					"#SYSTEM", phaseCode, (endTime - beginTime), heapSize,
					"", ""], " ", "", Int.MAX_VALUE));
			}

			for (market in markets) {
				market.updateTime();
			}
		}


		//////// AGENTS INSTANTIATION & INITIALIZATION ////////

		agents.clear();
		localAgents.clear();
		globalAgents.clear();

		for (market in spotMarkets) {
			val i = market.id;
			val v = config("spot-markets")([i, "default"]);
			val N = v("#agents").toLong();
			val a = createLocalAgents(v("agent"), market, N);
			agents.addAll(a);
			localAgents.addAll(a);
		}

		for (market in indexMarkets) {
			val i = market.id - SPOT_MARKETS_COUNT;
			val v = config("index-markets")([i, "default"]);
			val N = v("#agents").toLong();
			val a = createLocalAgents(v("agent"), market, N);
			agents.addAll(a);
			localAgents.addAll(a);
		}

		for (market in indexMarkets) {
			val v = config("arbitrage-market")("default");
			val N = v("#agents").toLong();
			val a = createArbitrageAgents(v("agent"), market, N);
			agents.addAll(a);
			globalAgents.addAll(a);
		}


		//////// THEORETICAL TIME WINDOW SIZES ////////

		LARGEST_TIME_WINDOW_SIZE = Long.MIN_VALUE;
		AVERAGE_TIME_WINDOW_SIZES.clear();
		for (market in spotMarkets) {
			val i = market.id;
			val v = config("spot-markets")([i, "default"]);
			val N = v("#agents").toLong();
			val windowSize = computeAverageTimeWindowSize(v("agent"), market, N);
			AVERAGE_TIME_WINDOW_SIZES.put(market, windowSize);
			LARGEST_TIME_WINDOW_SIZE = Math.max(LARGEST_TIME_WINDOW_SIZE, windowSize as Long);
		}
		for (market in indexMarkets) {
			val i = market.id - SPOT_MARKETS_COUNT;
			val v = config("index-markets")([i, "default"]);
			val N = v("#agents").toLong();
			val windowSize = computeAverageTimeWindowSize(v("agent"), market, N);
			AVERAGE_TIME_WINDOW_SIZES.put(market, windowSize);
			LARGEST_TIME_WINDOW_SIZE = Math.max(LARGEST_TIME_WINDOW_SIZE, windowSize as Long);
		}

		Console.OUT.println("# LARGEST_TIME_WINDOW_SIZE " + LARGEST_TIME_WINDOW_SIZE);


		////////////////////////////////////
		//////// PHASE 1: TRANSIENT ////////
		////////////////////////////////////

		val ARBITRAGE_MAX_INTRUSION_COUNT = config("arbitrage-market")("max-intrusion-count").toLong();

		val MARKET_TRANSIENT = Math.max(LARGEST_TIME_WINDOW_SIZE, MINIMUM_TRANSIENT_STEPS) / 1;
		for (t in 1..MARKET_TRANSIENT) {
			if (SYSTEM_GC_EVERY_LOOP) {
				System.gc();
			}

			var beginTime:Long = System.nanoTime();
			var endTime:Long;
			var heapSize:Long;

			// No circuit breaker; No market attack.
			val allOrders = new ArrayList[Order]();

			if (MARKET_UPDATE == MARKET_UPDATE_ONE_AGENT_ONE_ORDER) {
				if (indexMarkets.size() > 0) {
					doArbitrageUpdate(ARBITRAGE_MAX_INTRUSION_COUNT, globalAgents, indexMarkets, allOrders);
				}
				doOneAgentOneOrderUpdate(localAgents, markets, allOrders);
			}
			if (MARKET_UPDATE == MARKET_UPDATE_ONE_MARKET_ONE_ORDER) {
				if (indexMarkets.size() > 0) {
					doArbitrageUpdate(ARBITRAGE_MAX_INTRUSION_COUNT, globalAgents, indexMarkets, allOrders);
				}
				doOneMarketOneOrderUpdate(localAgents, markets, allOrders);
			}
			if (MARKET_UPDATE == MARKET_UPDATE_ASYNC_BATCH_ORDER) {
				//val ARBITRAGE_MAX_INTRUSION_COUNT = 0;
				val localOrders = collectOrdersByLocalAgents(localAgents, markets);
				val globalOrders = handleOrdersWithArbitrageurs(localOrders, ARBITRAGE_MAX_INTRUSION_COUNT, globalAgents, indexMarkets);
				for (orders in localOrders) {
					allOrders.addAll(orders);
				}
				for (orders in globalOrders) {
					allOrders.addAll(orders);
				}
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

			val phaseCode = 1;
			print(phaseCode, agents, markets, allOrders);
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
					"#SYSTEM", phaseCode, (endTime - beginTime), heapSize,
					"", ""], " ", "", Int.MAX_VALUE));
			}

			for (market in markets) {
				market.updateTime();
			}
		}


		//////// MARKET RULES & REGULATIONS ////////

		val marketRules = new ArrayList[MarketRule]();
		for (i in 0..(config("market-rules").size() - 1)) {
			val v = config("market-rules")(i);
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
			val AVERAGE_TIME_WINDOW_SIZE = AVERAGE_TIME_WINDOW_SIZES.get(market)();
			val timeLength = (AVERAGE_TIME_WINDOW_SIZE * v("time-length").toDouble()) as Long;
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


		//////// MARKET ATTACKS ////////

		val marketAttacks = new ArrayList[MarketAttack]();
		for (i in 0..(config("market-attacks").size() - 1)) {
			val v = config("market-attacks")(i);
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
				marketAttacks.add(new FundamentalPriceAttack(fundamentals, market, market.getTime() + time, priceImpact));

				Console.OUT.println("# FUNDAMENTAL PRICE ATTACK (no." + i + ")");
				Console.OUT.println("#   market.id " + market.id);
				Console.OUT.println("#   time " + (market.getTime() + time));
				Console.OUT.println("#   priceImpact " + priceImpact);
			}
			if (v("class").toString().equals("MarketPriceAttack")) {
				val time = v("time").toLong();
				val priceImpact = v("price-impact").toDouble();
				val volumeImpact = v("volume-impact").toDouble();
				marketAttacks.add(new MarketPriceAttack(market, market.getTime() + time, priceImpact, volumeImpact));

				Console.OUT.println("# MARKET PRICE ATTACK (no." + i + ")");
				Console.OUT.println("#   market.id " + market.id);
				Console.OUT.println("#   time " + (market.getTime() + time));
				Console.OUT.println("#   priceImpact " + priceImpact);
				Console.OUT.println("#   volumeImpact " + volumeImpact);
			}
		}


		/////////////////////////////////////
		//////// PHASE 2: SIMULATION ////////
		/////////////////////////////////////
		
		val TIME_SIMULATION_BEGIN = System.nanoTime();

		for (t in 1..MARKET_ITERATION) {
			if (SYSTEM_GC_EVERY_LOOP) {
				System.gc();
			}

			var beginTime:Long = System.nanoTime();
			var endTime:Long;
			var heapSize:Long;

			val allOrders = new ArrayList[Order]();

			if (MARKET_UPDATE == MARKET_UPDATE_ONE_AGENT_ONE_ORDER) {
				if (indexMarkets.size() > 0) {
					doArbitrageUpdate(ARBITRAGE_MAX_INTRUSION_COUNT, globalAgents, indexMarkets, allOrders);
				}
				doOneAgentOneOrderUpdate(localAgents, markets, allOrders);
			}
			if (MARKET_UPDATE == MARKET_UPDATE_ONE_MARKET_ONE_ORDER) {
				if (indexMarkets.size() > 0) {
					doArbitrageUpdate(ARBITRAGE_MAX_INTRUSION_COUNT, globalAgents, indexMarkets, allOrders);
				}
				doOneMarketOneOrderUpdate(localAgents, markets, allOrders);
			}
			if (MARKET_UPDATE == MARKET_UPDATE_ASYNC_BATCH_ORDER) {
				//val ARBITRAGE_MAX_INTRUSION_COUNT = 0;
				val localOrders = collectOrdersByLocalAgents(localAgents, markets);
				val globalOrders = handleOrdersWithArbitrageurs(localOrders, ARBITRAGE_MAX_INTRUSION_COUNT, globalAgents, indexMarkets);
				for (orders in localOrders) {
					allOrders.addAll(orders);
				}
				for (orders in globalOrders) {
					allOrders.addAll(orders);
				}
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
			
			val phaseCode = 2;
			print(phaseCode, agents, markets, allOrders);
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
					"#SYSTEM", phaseCode, (endTime - beginTime), heapSize,
					"", ""], " ", "", Int.MAX_VALUE));
			}

			for (rule in marketRules) {
				rule.update();
			}
			
			for (market in markets) {
				market.updateTime();
			}
		}

		val TIME_SIMULATION_END = System.nanoTime();

		for (rule in marketRules) {
			val cbrule = rule as CircuitBreaker;
			Console.OUT.println("#CIRCUIT-BRAKER " + cbrule.market.id + " " + cbrule.activationCount);
		}

		val TIME_THE_END = System.nanoTime();

		Console.OUT.println(StringUtil.formatArray([
			"#TIME", 
			((TIME_THE_END - TIME_THE_BEGINNING) / 1e+9),
			((TIME_CONFIGURE_END - TIME_CONFIGURE_BEGIN) / 1e+9),
			((TIME_SIMULATION_END - TIME_SIMULATION_BEGIN) / 1e+9),
			"", ""], " ", "", Int.MAX_VALUE));
	}


	public static def main(args:Rail[String]) {
		new Main05().run(args);
	}
}

