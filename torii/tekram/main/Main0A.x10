package tekram.main;
import x10.compiler.Profile;
import x10.io.File;
import x10.util.ArrayList;
import x10.util.HashMap;
import x10.util.List;
import x10.util.Random;
import x10.util.StringUtil;
import tekram.Agent;
import tekram.Global;
import tekram.Market;
import tekram.Order;
import tekram.util.Cholesky;
import tekram.util.Gaussian;
import tekram.util.JSON;
import tekram.util.MultiGeomBrownian;
import tekram.util.RandomPermutation;

public class Main0A {


	public static def print(phaseCode:Long, agents:List[Agent], markets:List[Market]) {
		for (market in markets) {
			val t = market.getTime();
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
				//
//				marketIndex,
//				fundamentalIndex,
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


	//TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO 
	//TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO 
	public def collectOrdersByLocalAgents(agents:List[Agent], markets:List[Market]):List[List[Order]] {

		val allOrders = new ArrayList[List[Order]]();
		
		val N_PLACES = Place.numPlaces(); //Long.parse(System.getenv("X10_NPLACES"));
		val N_THREADS = 1; //Long.parse(System.getenv("X10_NTHREADS"));
		val WORKLOAD_TYPE = Long.parse(System.getenv("WORKLOAD_TYPE"));
		val WORKLOAD_TIME = Long.parse(System.getenv("WORKLOAD_TIME"));
		val places = Place.places();

		val profile = new Runtime.Profile();

		val TYPE_SLEEP = 0;
		val TYPE_INTEGRAL = 1;

		val MODE = 2;

		if (MODE == 1) {
			val beginTime = System.nanoTime();
			Console.OUT.println("#N_THREADS " + N_THREADS);
			val N = agents.size();
			finish {
				for (t in 0..(N_THREADS - 1)) {
					async {
						val random = new Random();
						val tempOrders = new ArrayList[List[Order]]();
						for (var i:Long = t; i < N; i += N_THREADS) {
							val agent = agents(i);
							val orders = agent.placeOrders(markets);
							tempOrders.add(orders);

							if (WORKLOAD_TYPE == TYPE_SLEEP) {
								System.threadSleep(WORKLOAD_TIME);
							}
							if (WORKLOAD_TYPE == TYPE_INTEGRAL) {
								val _beginTime = System.nanoTime();
								var sum:Double = 0.0;
								while ((System.nanoTime() - _beginTime) < WORKLOAD_TIME * 1e+6) {
									val d = random.nextDouble();
									sum += d;
								}
							}
						}
						atomic allOrders.addAll(tempOrders);
					}
				}
			}
			val endTime = System.nanoTime();
			Console.OUT.println("#ASYNC " + ((endTime - beginTime) / 1e+9));
		}

		if (MODE == 2) {
			val beginTime = System.nanoTime();
			Console.OUT.println("#N_PLACES " + N_PLACES);
			Console.OUT.println("#N_THREADS " + N_THREADS);
			finish {
				val allOrdersRef = new GlobalRef[List[List[Order]]](allOrders);

				val mapPlaceMarket = new HashMap[Place,List[Market]]();
				for (p in 0..(N_PLACES - 1)) {
					mapPlaceMarket.put(places(p), new ArrayList[Market]());
				}
				for (i in 0..(markets.size() - 1)) {
					val p = i % N_PLACES;
					val market = markets(i);
					mapPlaceMarket(places(p)).add(market);
					val t = market.getTime(); 
					at (places(p)) Console.OUT.println("Assign market " + i + " to place " + p + " at " + t + " on " + Runtime.getName());
				}

				for (p in 0..(N_PLACES - 1)) {
					// LocalEnv
					val _markets = mapPlaceMarket(places(p));
					val _agents = new ArrayList[Agent]();
					for (market in _markets) {
						for (agent in agents) {
							if (agent.isMarketAccessible(market)) {
								_agents.add(agent);
							}
						}
					}

					async @Profile(profile) at (places(p)) {
						Console.OUT.println("#HOST: " + Runtime.getName());
			
						val N = _agents.size();
						val _allOrders = new ArrayList[List[Order]]();

							val t = 0;
						//finish for (t in 0..(N_THREADS - 1)) async {
							val random = new Random();
							val tempOrders = new ArrayList[List[Order]]();
							for (var i:Long = t; i < N; i += N_THREADS) {
								val agent = _agents(i);
								val orders = agent.placeOrders(_markets);
								tempOrders.add(orders);

								if (WORKLOAD_TYPE == TYPE_SLEEP) {
									System.threadSleep(WORKLOAD_TIME);
								}
								if (WORKLOAD_TYPE == TYPE_INTEGRAL) {
									val _beginTime = System.nanoTime();
									var sum:Double = 0.0;
									while ((System.nanoTime() - _beginTime) < WORKLOAD_TIME * 1e+6) {
										val d = random.nextDouble();
										sum += d;
									}
								}
							}
						//	atomic _allOrders.addAll(tempOrders);
						//}
							_allOrders.addAll(tempOrders);

						at (allOrdersRef.home) {
							atomic allOrdersRef().addAll(_allOrders);
						}
					}
				}
			}
			val endTime = System.nanoTime();
			val seriByte = profile.bytes;
			val commTime = profile.communicationNanos;
			val seriTime = profile.serializationNanos;
			Console.OUT.println("#ASYNC " + ((endTime - beginTime) / 1e+9));
			Console.OUT.println("#PROFILE " + seriByte / N_PLACES + " byte/place");
			Console.OUT.println("#PROFILE " + commTime / 1e+9 / N_PLACES + " sec/place (comm)");
			Console.OUT.println("#PROFILE " + seriTime / 1e+9 / N_PLACES + " sec/place (seri)");
		}

		return allOrders;
	}

	public def handleOrdersWithArbitrageurs(localOrders:List[List[Order]]):List[List[Order]] {
		val random = RANDOM;

		val allOrders = new ArrayList[List[Order]]();

		val randomOrders = new RandomPermutation[List[Order]](random, localOrders);

		randomOrders.shuffle();
		for (someOrders in randomOrders) {
			// This handles one order-list submitted by an agent per loop.
			// TODO: If needed, one-market one-order handling.
			for (order in someOrders) {
				order.getMarket().handleOrder(order); // NOTE: DO it now.
			}
		}
		return allOrders;
	}
	//TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO 
	//TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO 


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
		for (i in 0..(N - 1)) {
			cor(i)(i) = 1.0;
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


	public def createLocalAgents(config:JSON.Value, market:Market, N:Long):List[Agent] {
		val AGENTS_COUNT = N;

		val agents = new ArrayList[Agent]();

		for (i in 0..(AGENTS_COUNT - 1)) {
			val id = agents.size();
			val agent = new Agent(id);
			agent.setMarketAccessible(market);
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
		val MARKET_UPDATE_ASYNC_BATCH_ORDER = 0x3;
		val MARKET_UPDATE = MARKET_UPDATE_ASYNC_BATCH_ORDER;
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

		for (i in 0..(SPOT_MARKETS_COUNT - 1)) {
			val id = markets.size();
			val market = new Market(id);
			markets.add(market);
		}


		//////// MARKETS INITIALIZATION ////////

		for (market in markets) {
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


		//////// SIMULATION WITHIN THREE PHASES ////////
		// SETUP AGENTS FOR INITIATION
		// PHASE 0: INITIATION ... dummy historical data with `init-agent` parameters
		// SETUP AGENTS FOR SIMULATION
		// PHASE 1: TRANSIENT  ... free run with `agent` parameters
		// PHASE 2: SIMULATION ... actual run with `agent` parameters
		////////////////////////////////////////////////


		//////// AGENTS INSTANTIATION & INITIALIZATION ////////

		val agents = new ArrayList[Agent]();

		for (market in markets) {
			val i = market.id;
			val v = config("spot-markets")([i, "default"]);
			val N = v("#init-agents").toLong();
			val a = createLocalAgents(v("init-agent"), market, N);
			agents.addAll(a);
		}


		val TIME_CONFIGURE_END = System.nanoTime();


		/////////////////////////////////////
		//////// PHASE 0: INITIATION ////////
		/////////////////////////////////////

		for (market in markets) {
			market.setRunning(false);
		}

		// To fill with fundamental prices/returns, to initiate the trends.
		// No trading; No circuit breaker; No market attack; No printing.
		val MARKET_INITIATION = MINIMUM_INITIATION_STEPS;
		for (t in 1..MARKET_INITIATION) {
			fundamentals.nextBrownian();
			for (market in markets) {
				val nextFundamental = fundamentals.get(market.id);
				market.updateMarketPrice(nextFundamental);
				market.updateFundamentalPrice(nextFundamental);
				market.updateOrderBooks();
				market.updateTime();
			}
		}

		// To fill order books with orders; no execution allowed.
		for (t in 1..MARKET_INITIATION) {

			if (MARKET_UPDATE == MARKET_UPDATE_ASYNC_BATCH_ORDER) {
				val localOrders = collectOrdersByLocalAgents(agents, markets);
				val globalOrders = handleOrdersWithArbitrageurs(localOrders);
			}

			// No trading; No circuit breaker; No market attack; No printing.
			fundamentals.nextBrownian();
			for (market in markets) {
				val nextFundamental = fundamentals.get(market.id);
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

			if (MARKET_UPDATE == MARKET_UPDATE_ASYNC_BATCH_ORDER) {
				val localOrders = collectOrdersByLocalAgents(agents, markets);
				val globalOrders = handleOrdersWithArbitrageurs(localOrders);
			}

			fundamentals.nextBrownian();
			for (market in markets) {
				val nextFundamental = fundamentals.get(market.id);
				market.updateMarketPrice();
				market.updateFundamentalPrice(nextFundamental);
				market.updateOrderBooks();
			}
			
			val phaseCode = 0;
			print(phaseCode, agents, markets);

			for (market in markets) {
				market.updateTime();
			}
		}


		//////// AGENTS INSTANTIATION & INITIALIZATION ////////

		agents.clear();

		for (market in markets) {
			val i = market.id;
			val v = config("spot-markets")([i, "default"]);
			val N = v("#agents").toLong();
			val a = createLocalAgents(v("agent"), market, N);
			agents.addAll(a);
		}


		////////////////////////////////////
		//////// PHASE 1: TRANSIENT ////////
		////////////////////////////////////

		val MARKET_TRANSIENT = MINIMUM_TRANSIENT_STEPS;
		for (t in 1..MARKET_TRANSIENT) {
			if (SYSTEM_GC_EVERY_LOOP) {
				System.gc();
			}

			// No circuit breaker; No market attack.

			if (MARKET_UPDATE == MARKET_UPDATE_ASYNC_BATCH_ORDER) {
				val localOrders = collectOrdersByLocalAgents(agents, markets);
				val globalOrders = handleOrdersWithArbitrageurs(localOrders);
			}
			
			fundamentals.nextBrownian();
			for (market in markets) {
				val nextFundamental = fundamentals.get(market.id);
				market.updateMarketPrice();
				market.updateFundamentalPrice(nextFundamental);
				market.updateOrderBooks();
			}

			val phaseCode = 1;
			print(phaseCode, agents, markets);

			for (market in markets) {
				market.updateTime();
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

			if (MARKET_UPDATE == MARKET_UPDATE_ASYNC_BATCH_ORDER) {
				val localOrders = collectOrdersByLocalAgents(agents, markets);
				val globalOrders = handleOrdersWithArbitrageurs(localOrders);
				Console.OUT.println([localOrders.size(), globalOrders.size()]);
			}
			
			fundamentals.nextBrownian();
			for (market in markets) {
				val nextFundamental = fundamentals.get(market.id);
				market.updateMarketPrice();
				market.updateFundamentalPrice(nextFundamental);
				market.updateOrderBooks();
			}
			
			val phaseCode = 2;
			print(phaseCode, agents, markets);

			for (market in markets) {
				market.updateTime();
			}
		}

		val TIME_SIMULATION_END = System.nanoTime();

		val TIME_THE_END = System.nanoTime();

		Console.OUT.println(StringUtil.formatArray([
			"#TIME", 
			((TIME_THE_END - TIME_THE_BEGINNING) / 1e+9),
			((TIME_CONFIGURE_END - TIME_CONFIGURE_BEGIN) / 1e+9),
			((TIME_SIMULATION_END - TIME_SIMULATION_BEGIN) / 1e+9),
			"", ""], " ", "", Int.MAX_VALUE));
	}


	public static def main(args:Rail[String]) {
		new Main0A().run(args);
	}
}

