package samples.Option;
import x10.util.ArrayList;
import x10.util.List;
import plham.Agent;
import plham.Market;
import plham.util.JSON;
import plham.util.JSONRandom;
import plham.main.SequentialRunner;
import samples.CI2002.CI2002Main;

public class OptionMain extends CI2002Main {

	public static def main(args:Rail[String]) {
		new SequentialRunner(new OptionMain()).run(args);
	}

	public def print(sessionName:String) {
		super.print(sessionName);
		checkZeroSumGame();
	}

	public def checkZeroSumGame() {
		val markets = getMarketsByName("markets");
		val agents = getAgentsByName("agents");

		var cashAmount:Double = 0.0;
		var cashAmountAbs:Double = 0.0;
		val assetVolumes = new Rail[Long](markets.size());
		val assetVolumesAbs = new Rail[Long](markets.size());
		for (agent in agents) {
			cashAmount += agent.getCashAmount();
			cashAmountAbs += Math.abs(agent.getCashAmount());
			for (market in markets) {
				if (agent.isMarketAccessible(market)) {
					assetVolumes(market.id) += agent.getAssetVolume(market);
					assetVolumesAbs(market.id) += Math.abs(agent.getAssetVolume(market));
				}
			}
		}
		Console.OUT.print("#ZEROSUM");
		Console.OUT.print(" " + cashAmount);
		for (market in markets) {
			Console.OUT.print(" " + assetVolumes(market.id));
		}
		Console.OUT.print(" " + cashAmountAbs);
		for (market in markets) {
			Console.OUT.print(" " + assetVolumesAbs(market.id));
		}
		Console.OUT.println();
	}

	public def createOptionMarkets(json:JSON.Value, random:JSONRandom) {
		val underlying = getMarketByName(json("markets")(0));
		var list:JSON.Value;

		val strikePrices = new ArrayList[Double]();
		list = json("strikePrices");
		for (i in 0..(list.size() - 1)) {
			val strikePrice = list(i).toDouble();
			strikePrices.add(strikePrice);
		}
		strikePrices.sort();

		val maturityTimes = new ArrayList[Long]();
		list = json("maturityTimes");
		for (i in 0..(list.size() - 1)) {
			val maturityTime = list(i).toLong();
			maturityTimes.add(maturityTime);
		}
		maturityTimes.sort();

		val markets = new ArrayList[Market]();

		for (strikePrice in strikePrices) {
			for (maturityTime in maturityTimes) {
				for (k in 0..1) { // Call and Put pairs
					val kindName = (k == 0) ? "Call" : "Put";
					val market = new OptionMarket();
					//setupMarket(market, json, random);
					market.setTickSize(random.nextRandom(json("tickSize", "-1.0"))); // " tick-size <= 0.0 means no tick size.
					market.setInitialMarketPrice(strikePrice);
					market.setInitialFundamentalPrice(strikePrice);
					market.setOutstandingShares(random.nextRandom(json("outstandingShares")) as Long);
					market.kind = kindName.equals("Call") ? OptionMarket.KIND_CALL_OPTION : OptionMarket.KIND_PUT_OPTION;
					market.setUnderlyingMarket(underlying);
					market.setStrikePrice(strikePrice);
					market.setMaturityInterval(maturityTime);
					markets.add(market);

					Console.OUT.println("# " + json("class").toString() + "" + [kindName, underlying.id, (strikePrice as Long), maturityTime] + " : " + JSON.dump(json));
				}
			}
		}
		return markets;
	}


	public def createAgents(json:JSON.Value):List[Agent] {
		val random = new JSONRandom(getRandom());
		val agents = super.createAgents(json);
		if (json("class").equals("OptionAgent")) {
			val numAgents = json("numAgents").toLong();
			for (i in 0..(numAgents - 1)) {
				val agent = new OptionAgent();
				agent.underlyingId = getMarketByName(json("markets")).id;
				agents.add(agent);
			}
			Console.OUT.println("# " + json("class").toString() + " : " + JSON.dump(json));
		}
		return agents;
	}


	public def setupOptionMarket(market:OptionMarket, json:JSON.Value, random:JSONRandom) {
		setupMarket(market, json, random);
		market.kind = json("kind").equals("Call") ? OptionMarket.KIND_CALL_OPTION : OptionMarket.KIND_PUT_OPTION;
		market.setUnderlyingMarket(getMarketByName(json("markets")(0)));
		market.setStrikePrice(json("strikePrice").toDouble());
		market.setMaturityInterval(json("maturity").toLong());
	}

	public def createMarkets(json:JSON.Value):List[Market] {
		val random = new JSONRandom(getRandom());
		val markets = super.createMarkets(json);
		if (json("class").equals("OptionMarket")) {
			val market = new OptionMarket();
			setupOptionMarket(market, json, random);
			markets.add(market);

			Console.OUT.println("# " + json("class").toString() + " : " + JSON.dump(json));
		}
		if (json("class").equals("OptionMarketCluster")) {
			markets.addAll(createOptionMarkets(json, random));
		}
		return markets;
	}
}
