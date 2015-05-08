package tekram;
import x10.util.ArrayList;
import x10.util.List;
import x10.util.Random;
import tekram.util.Counter;
import tekram.util.Gaussian;

public class Market(id:Long) {
	
	public var _isRunning:Boolean;
	public var buyOrderBook:OrderBook;
	public var sellOrderBook:OrderBook;
	public var outstandingShares:Long;

	public var marketPrices:List[Double];
	public var marketReturns:List[Double];
	public var fundamentalPrices:List[Double];
	public var fundamentalReturns:List[Double];

	public var lastExecutedPrices:List[Double];
	public var buyOrdersCounts:List[Long];
	public var sellOrdersCounts:List[Long];
	public var executedOrdersCounts:List[Long];

	public var time:Long;
//	public var tick:Long;

	public def this(id:Long) {
		property(id);
		this._isRunning = true;
		this.buyOrderBook = new OrderBook(OrderBook.HIGHERS_FIRST);
		this.sellOrderBook = new OrderBook(OrderBook.LOWERS_FIRST);
		this.outstandingShares = 1;
		this.time = 0;

		this.marketPrices = new ArrayList[Double]();
		this.marketReturns = new ArrayList[Double]();
		this.fundamentalPrices = new ArrayList[Double]();
		this.fundamentalReturns = new ArrayList[Double]();

		this.lastExecutedPrices = new ArrayList[Double]();
		this.buyOrdersCounts = new ArrayList[Long]();
		this.sellOrdersCounts = new ArrayList[Long]();
		this.executedOrdersCounts = new ArrayList[Long]();
	}

	public def handleOrders(orders:List[Order]) {
		for (order in orders) {
			this.handleOrder(order);
		}
	}
	
	public def handleOrder(order:Order) {
		assert order.getMarket() == this;
		val t = this.getTime();
		if (order.getPrice() <= 0.0) {
			return;
		}
		if (order.getVolume() <= 0) {
			return;
		}
		if (order.isBuyOrder()) {
			if (this.isRunning()) {
				this.handleBuyOrder(order);
			} else {
				this.buyOrderBook.add(order);
			}
			this.buyOrdersCounts(t) += 1;
		}
		if (order.isSellOrder()) {
			if (this.isRunning()) {
				this.handleSellOrder(order);
			} else {
				this.sellOrderBook.add(order);
			}
			this.sellOrdersCounts(t) += 1;
		}
	}
	
	protected def handleBuyOrder(buyOrder:Order) {
		assert buyOrder.isBuyOrder();
		val t = this.getTime();

		while (buyOrder.getVolume() > 0) {
			if (this.sellOrderBook.size() == 0) {
				break;
			}
			val sellOrder = this.sellOrderBook.getBestPricedOrder();
			if (buyOrder.getPrice() >= sellOrder.getPrice()) {
				this.executeBuyOrders(buyOrder, sellOrder);
				this.executedOrdersCounts(t) += 1;
				this.lastExecutedPrices(t) = sellOrder.getPrice();
			} else {
				break;
			}
			if (sellOrder.getVolume() <= 0) {
				this.sellOrderBook.remove(sellOrder);
			}
		}
		if (buyOrder.getVolume() > 0) {
			this.buyOrderBook.add(buyOrder);
		}
	}

	protected def handleSellOrder(sellOrder:Order) {
		assert sellOrder.isSellOrder();
		val t = this.getTime();

		while (sellOrder.getVolume() > 0) {
			if (this.buyOrderBook.size() == 0) {
				break;
			}
			val buyOrder = this.buyOrderBook.getBestPricedOrder();
			if (buyOrder.getPrice() >= sellOrder.getPrice()) {
				this.executeSellOrders(sellOrder, buyOrder);
				this.executedOrdersCounts(t) += 1;
				this.lastExecutedPrices(t) = buyOrder.getPrice();
			} else {
				break;
			}
			if (buyOrder.getVolume() <= 0) {
				this.buyOrderBook.remove(buyOrder);
			}
		}
		if (sellOrder.getVolume() > 0) {
			this.sellOrderBook.add(sellOrder);
		}
	}

	protected def executeBuyOrders(buyOrder:Order, sellOrder:Order) {
		if (Global.DEBUG > 0) {
			Console.OUT.println("Market.executeBuyOrder(): buyOrder: " + buyOrder);
			Console.OUT.println("Market.executeSellOrder(): sellOrder: " + sellOrder);
		}
		assert buyOrder.getMarket() == sellOrder.getMarket();
		val market = buyOrder.getMarket();

		val exchangePrice = sellOrder.getPrice();
		val exchangeVolume = Math.min(buyOrder.getVolume(), sellOrder.getVolume());
		val cashAmountDelta = exchangePrice * exchangeVolume;
		val assetVolumeDelta = exchangeVolume;
		assert exchangeVolume > 0;
		
		buyOrder.getAgent().updateCashAmount(-cashAmountDelta);
		buyOrder.getAgent().updateAssetVolume(market, +assetVolumeDelta);
		
		sellOrder.getAgent().updateCashAmount(+cashAmountDelta);
		sellOrder.getAgent().updateAssetVolume(market, -assetVolumeDelta);

		buyOrder.updateVolume(-exchangeVolume);
		sellOrder.updateVolume(-exchangeVolume);

		assert exchangePrice >= 0.0 : ["executeBuyOrder(): exchangePrice >= 0.0", exchangePrice];
		assert exchangeVolume >= 0 : ["executeBuyOrder(): exchangeVolume >= 0", exchangeVolume];

		if (Global.DEBUG > 0) {
			Console.OUT.println("exchangePrice: " + exchangePrice);
			Console.OUT.println("exchangeVolume: " + exchangeVolume);
			Console.OUT.println("buyOrder.getVolume(): " + buyOrder.getVolume());
			Console.OUT.println("sellOrder.getVolume(): " + sellOrder.getVolume());
		}
	}
	
	protected def executeSellOrders(sellOrder:Order, buyOrder:Order) {
		if (Global.DEBUG > 0) {
			Console.OUT.println("Market.executeSellOrder(): buyOrder: " + buyOrder);
			Console.OUT.println("Market.executeSellOrder(): sellOrder: " + sellOrder);
		}
		assert sellOrder.getMarket() == buyOrder.getMarket();
		val market = sellOrder.getMarket();

		val exchangePrice = buyOrder.getPrice();
		val exchangeVolume = Math.min(buyOrder.getVolume(), sellOrder.getVolume());
		val cashAmountDelta = exchangePrice * exchangeVolume;
		val assetVolumeDelta = exchangeVolume;
		assert exchangeVolume > 0;
		
		buyOrder.getAgent().updateCashAmount(-cashAmountDelta);
		buyOrder.getAgent().updateAssetVolume(market, +assetVolumeDelta);
		
		sellOrder.getAgent().updateCashAmount(+cashAmountDelta);
		sellOrder.getAgent().updateAssetVolume(market, -assetVolumeDelta);

		buyOrder.updateVolume(-exchangeVolume);
		sellOrder.updateVolume(-exchangeVolume);

		assert exchangePrice >= 0.0 : ["executeSellOrder(): exchangePrice >= 0.0", exchangePrice];
		assert exchangeVolume >= 0 : ["executeSellOrder(): exchangeVolume >= 0", exchangeVolume];

		if (Global.DEBUG > 0) {
			Console.OUT.println("exchangePrice: " + exchangePrice);
			Console.OUT.println("exchangeVolume: " + exchangeVolume);
			Console.OUT.println("buyOrder.getVolume(): " + buyOrder.getVolume());
			Console.OUT.println("sellOrder.getVolume(): " + sellOrder.getVolume());
		}
	}

	/**
	 * This emulateOrder() is similar to handleOrder() but it actually do
	 * nothing and not change the internal state of this market.
	 * It returns the first matching order in the opposite orderbook;
	 * otherwise, no transaction, it returns null.
	 * The price of the matching order will be the next market price,
	 * if the transaction occurs between them.
	 * Thus it is useful to predict a future of this market.
	 * The primary user of this method emulateOrder() will be a market rule.
	 */
	public def emulateOrder(order:Order):Order {
		assert order.getMarket() == this;

		if (order.getPrice() <= 0.0) {
			return null;
		}
		if (order.getVolume() <= 0) {
			return null;
		}
		if (order.isBuyOrder()) {
			return this.emulateBuyOrder(order);
		}
		if (order.isSellOrder()) {
			return this.emulateSellOrder(order);
		}
		return null;
	}

	protected def emulateBuyOrder(buyOrder:Order):Order {
		assert buyOrder.isBuyOrder();

		if (buyOrder.getVolume() > 0 && this.sellOrderBook.size() > 0) {
			val sellOrder = this.sellOrderBook.getBestPricedOrder();
			if (buyOrder.getPrice() >= sellOrder.getPrice()) {
				return sellOrder;
			}
		}
		return null;
	}
	
	protected def emulateSellOrder(sellOrder:Order):Order {
		assert sellOrder.isSellOrder();

		if (sellOrder.getVolume() > 0 && this.buyOrderBook.size() > 0) {
			val buyOrder = this.buyOrderBook.getBestPricedOrder();
			if (buyOrder.getPrice() >= sellOrder.getPrice()) {
				return buyOrder;
			}
		}
		return null;
	}
	
	public def isRunning():Boolean {
		return _isRunning;
	}
	
	public def setRunning(isRunning:Boolean) {
		this._isRunning = isRunning;
	}

	public def updateOrderBooks() {
		this.buyOrderBook.removeZeroVolumeOrders();
		this.sellOrderBook.removeZeroVolumeOrders();
		this.buyOrderBook.removeExpiredOrders();
		this.sellOrderBook.removeExpiredOrders();
	}
	
	/**
	 * Return the next market price at t + 1.
	 * The value depends on transactions occurred after the previous price update.
	 * This method does not change any internal state of this market;
	 * Use updateMarketPrice() for this purpose.
	 */
	public def getNextMarketPrice():Double {
		val lastPrice = this.marketPrices.getLast();
		var price:Double = lastPrice;
		if (this.isRunning()) {
			if (this.executedOrdersCounts.getLast() > 0) {
				price = this.lastExecutedPrices.getLast();
			} else if (this.buyOrderBook.size() > 0 && this.sellOrderBook.size() > 0) {
				val bidPrice = this.buyOrderBook.getBestPrice();
				val askPrice = this.sellOrderBook.getBestPrice();
				price = (askPrice + bidPrice) / 2.0;
			}
		}
		return price;
	}

	public def updateMarketPrice() {
		val price = this.getNextMarketPrice();
		this.updateMarketPrice(price);
	}
	
	public def updateMarketPrice(price:Double) {
		assert !price.isNaN() : "!price.isNaN()";
		assert price >= 0.0 : "price >= 0.0";
		val lastPrice = this.marketPrices.getLast();
		this.marketPrices.add(price);
		this.marketReturns.add(price / lastPrice);

		// FIXME: The below should not come here.
		this.buyOrdersCounts.add(0);
		this.sellOrdersCounts.add(0);
		this.executedOrdersCounts.add(0);
		this.lastExecutedPrices.add(Double.NaN);
	}
	
	public def updateFundamentalPrice(fundamentalPrice:Double) {
		val lastFundamentalPrice = this.fundamentalPrices.getLast();
		this.fundamentalPrices.add(fundamentalPrice);
		this.fundamentalReturns.add(fundamentalPrice / lastFundamentalPrice);
	}
	
	public def setInitialMarketPrice(price:Double) {
		assert this.marketPrices.size() == 0;
		assert this.marketReturns.size() == 0;
		assert this.buyOrdersCounts.size() == 0;
		assert this.sellOrdersCounts.size() == 0;

		this.marketPrices.add(price); // t = 0
		this.marketReturns.add(1.0);  // t = 0
		this.lastExecutedPrices.add(Double.NaN);
		this.buyOrdersCounts.add(0);
		this.sellOrdersCounts.add(0);
		this.executedOrdersCounts.add(0);

		this.marketPrices.add(price); // t = 1
		this.marketReturns.add(1.0);  // t = 1
		this.lastExecutedPrices.add(Double.NaN);
		this.buyOrdersCounts.add(0);
		this.sellOrdersCounts.add(0);
		this.executedOrdersCounts.add(0);
	}
	
	public def setInitialFundamentalPrice(fundamentalPrice:Double) {
		assert this.fundamentalPrices.size() == 0;
		assert this.fundamentalReturns.size() == 0;
		
		this.fundamentalPrices.add(fundamentalPrice);
		this.fundamentalReturns.add(1.0);
		
		this.fundamentalPrices.add(fundamentalPrice);
		this.fundamentalReturns.add(1.0);
	}
	
	public def getMarketPrice() = this.marketPrices(this.getTime()); //this.marketPrices.getLast();

	public def getMarketPrice(t:Long):Double {
		assert t >= 0;
		return this.marketPrices(t);
	}

	public def getMarketReturn() = this.marketReturns(this.getTime()); //this.marketReturns.getLast();
	
	public def getMarketReturn(t:Long):Double {
		assert t >= 1;
		return this.marketReturns(t);
	}

	public def getFundamentalPrice() = this.fundamentalPrices(this.getTime()); //this.fundamentalPrices.getLast();
	
	public def getFundamentalPrice(t:Long):Double {
		assert t >= 1;
		return this.fundamentalPrices(t);
	}

	public def getFundamentalReturn() = this.fundamentalReturns(this.getTime()); //this.fundamentalReturns.getLast();
	
	public def getFundamentalReturn(t:Long):Double {
		assert t >= 1;
		return this.fundamentalReturns(t);
	}

	public def getBuyOrderBook() = this.buyOrderBook;

	public def getSellOrderBook() = this.sellOrderBook;

	public def getOutstandingShares():Long {
		assert this.outstandingShares >= 1;
		return this.outstandingShares;
	}

	public def setOutstandingShares(outstandingShares:Long) {
		this.outstandingShares = outstandingShares;
	}

	public def containsOrderOf(agent:Agent):Boolean {
		return this.buyOrderBook.containsOrderOf(agent) || this.sellOrderBook.containsOrderOf(agent);
	}

	public def getTime() = this.time;

	public def setTime(time:Long) {
		this.time = time;
	}

	public def updateTime() {
		this.time++; // Call this explicitly!
	}
	
	public def check() {
		val t = this.getTime();
		assert this.marketPrices.size() - 1 == t;
		assert this.marketReturns.size() - 1 == t;
		assert this.fundamentalPrices.size() - 1 == t;
		assert this.fundamentalReturns.size() - 1 == t;
		assert this.lastExecutedPrices.size() - 1 == t;
		assert this.buyOrdersCounts.size() - 1 == t;
		assert this.sellOrdersCounts.size() - 1 == t;
		assert this.executedOrdersCounts.size() - 1 == t;
	}
}
