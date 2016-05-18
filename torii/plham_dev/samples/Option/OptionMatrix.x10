package samples.Option;
import x10.util.List;
import x10.util.ArrayList;
import x10.util.Map;
import x10.util.HashMap;
import x10.util.Pair;
import plham.Market;
import plham.Order;
import plham.Agent;

public class OptionMatrix {

	public var underlyingId:Long;

	public var CALL:OptionTable;
	public var PUT:OptionTable;

	public def this(underlyingId:Long) {
		this.underlyingId = underlyingId;
		CALL = new OptionTable(OptionMarket.KIND_CALL_OPTION, underlyingId);
		PUT = new OptionTable(OptionMarket.KIND_PUT_OPTION, underlyingId);
	}

	public def this(underlying:Market) {
		this(underlying.id);
	}

	public def setup(markets:List[Market]) {
		CALL.tabulate(markets);
		PUT.tabulate(markets);
		check();
	}

	public def isReady():Boolean {
		return CALL != null && PUT != null;
	}

	public def numStrikePrices():Long = CALL.strikePrices.size();

	public def numMaturityTimes():Long = CALL.maturityTimes.size();

	public def toStrikePriceIndex(strikePrice:Double):Long = CALL.toStrikePriceIndex(strikePrice);

	public def toMaturityTimeIndex(maturityTime:Long):Long = CALL.toMaturityTimeIndex(maturityTime);

	public def getCallMarketId(strikePrice:Double, maturityTime:Long) = CALL.getMarketId(strikePrice, maturityTime);

	public def getPutMarketId(strikePrice:Double, maturityTime:Long) = PUT.getMarketId(strikePrice, maturityTime);

	public def getCallMarketIdByIndex(s:Long, u:Long) = CALL.getMarketIdByIndex(s, u);

	public def getPutMarketIdByIndex(s:Long, u:Long) = PUT.getMarketIdByIndex(s, u);

	public def check() {
		val C = CALL;
		val P = PUT;

		assert C.table.keySet().containsAll(P.table.keySet()) && P.table.keySet().containsAll(C.table.keySet()) : "Call and Put do not share keys";

		val n = C.strikePrices.size();
		val m = C.maturityTimes.size();

		val tol = 1e-2;
		for (s in 0..(n - 1)) {
			assert Math.abs(C.strikePrices(s) - P.strikePrices(s)) < tol;
		}
		for (u in 0..(m - 1)) {
			assert Math.abs(C.maturityTimes(u) - P.maturityTimes(u)) < tol;
		}

		val debug = true;
		if (debug) {
			for (u in 0..(m - 1)) {
				for (s in 0..(n - 1)) {
					Console.OUT.println("#OptionTables " + C.toString(s, u) + " | " + P.toString(s, u));
				}
			}
		}
	}

	static class OptionTable {

		static type Key = Pair[Long,Long];

		public var kind:OptionMarket.Kind;
		public var underlyingId:Long;

		public var strikePrices:List[Double] = new ArrayList[Double]();
		public var maturityTimes:List[Long] = new ArrayList[Long]();
		public var table:Map[Key,Long] = new HashMap[Key,Long]();

		public def this(kind:OptionMarket.Kind, underlyingId:Long) {
			this.kind = kind;
			this.underlyingId = underlyingId;
		}

		public def filterOptionMarkets(markets:List[Market]):List[OptionMarket] {
			val m = new ArrayList[OptionMarket]();
			for (market in markets) {
				if ((market instanceof OptionMarket) && ((market as OptionMarket).kind == kind) && (market as OptionMarket).getUnderlyingMarket().id == this.underlyingId) {
					m.add(market as OptionMarket);
				}
			}
			return m;
		}

		public def tabulate(markets:List[Market]) {
			val options = filterOptionMarkets(markets);

			strikePrices.clear();
			maturityTimes.clear();
			table.clear();

			for (market in options) {
				val strikePrice = market.getStrikePrice();
				val maturityTime = market.getMaturityInterval();
				if (!strikePrices.contains(strikePrice)) { // TODO
					strikePrices.add(strikePrice);
				}
				if (!maturityTimes.contains(maturityTime)) { // TODO
					maturityTimes.add(maturityTime);
				}
			}
			strikePrices.sort();  // For binarySearch
			maturityTimes.sort(); // For binarySearch

			for (market in options) {
				val strikePrice = market.getStrikePrice();
				val maturityTime = market.getMaturityInterval();

				val key = toKey(strikePrice, maturityTime);
				table(key) = market.id; // Locate the optionMarket at key = (s, u)

				val debug = true;
				if (debug) Console.OUT.println("#OptionTable[" + market.getKindName() + "," + underlyingId + "] " + toString(key));
			}
		}

		public def toStrikePriceIndex(strikePrice:Double):Long = ListUtils.binarySearchNearest(strikePrices, strikePrice);

		public def toMaturityTimeIndex(maturityTime:Long):Long = ListUtils.binarySearchNearest(maturityTimes, maturityTime);

		public def toKey(strikePrice:Double, maturityTime:Long) {
			val s = toStrikePriceIndex(strikePrice);
			val u = toMaturityTimeIndex(maturityTime);
			return Key(s, u);
		}

		public def getMarketId(strikePrice:Double, maturityTime:Long) {
			val key = toKey(strikePrice, maturityTime);
			return table(key);
		}

		public def getMarketIdByIndex(s:Long, u:Long) {
			val key = Key(s, u);
			return table(key);
		}

		/** For debug. **/
		public def toString(s:Long, u:Long) = toString(Key(s, u));

		/** For debug. **/
		public def toString(key:Key) {
			val s = key.first;
			val u = key.second;
			return "{" + key + " " + strikePrices(s) + " " + maturityTimes(u) + " " + table(key) + "}";
		}
	}
}
