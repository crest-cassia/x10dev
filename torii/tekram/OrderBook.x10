package tekram;
import x10.util.ArrayList;
import x10.util.List;
import x10.util.StringUtil;
import tekram.util.HeapQueue;

public class OrderBook {
	
	public var ordersList:HeapQueue[Order];
	
	public def this(comparator:(Order,Order)=>Int) {
		this.ordersList = new HeapQueue[Order](comparator);
	}
	
	public def size() = this.ordersList.size();
	
	public def add(order:Order) {
		this.ordersList.add(order);
	}
	
	public def remove(order:Order) {
		this.ordersList.remove(order);
	}

	public def getBestPricedOrder():Order {
		if (this.ordersList.size() > 0) {
			return this.ordersList.peek();
		}
		return null;
	}

	public def getBestPrice():Double {
		if (this.ordersList.size() > 0) {
			return this.ordersList.peek().getPrice();
		}
		return Double.NaN;
	}
	
	public def removeZeroVolumeOrders() {
		var n:Long = 0;
		val it = this.ordersList.iterator();
		while (it.hasNext()) {
			val order = it.next();
			if (order.getVolume() <= 0) {
				it.remove();
				n++;
			}
		}
		if (n > 0) {
			this.ordersList.heapify();
		}
	}
	
	public def removeExpiredOrders() {
		var n:Long = 0;
		val it = this.ordersList.iterator();
		while (it.hasNext()) {
			val order = it.next();
			if (order.isExpired()) {
				it.remove();
				n++;
			}
		}
		if (n > 0) {
			this.ordersList.heapify();
		}
	}
	
	public def getTotalPrice():Double {
		var total:Double = 0;
		for (order in this.ordersList) {
			total += order.getPrice();
		}
		return total;
	}

	public def getTotalVolume():Long {
		var total:Long = 0;
		for (order in this.ordersList) {
			total += order.getVolume();
		}
		return total;
	}

	public def getTotalVolume(condition:(Order)=>Boolean):Long {
		var total:Long = 0;
		for (order in this.ordersList) {
			if (condition(order)) {
				total += order.getVolume();
			}
		}
		return total;
	}

	public def containsOrderOf(agent:Agent):Boolean {
		for (order in this.ordersList) {
			if (order.getAgent() == agent) {
				return true;
			}
		}
		return false;
	}
	
	public def containsOrderOf(market:Market):Boolean {
		for (order in this.ordersList) {
			if (order.getMarket() == market) {
				return true;
			}
		}
		return false;
	}
	
	public static LOWERS_FIRST = (one:Order, other:Order) => {
		if (one.getPrice() < other.getPrice()) {
			return -1n;
		}
		if (one.getPrice() > other.getPrice()) {
			return +1n;
		}
		if (one.getTimePlaced() < other.getTimePlaced()) {
			return -1n;
		}
		if (one.getTimePlaced() > other.getTimePlaced()) {
			return +1n;
		}
		return 0n;
	};
	
	public static HIGHERS_FIRST = (one:Order, other:Order) => {
		if (one.getPrice() > other.getPrice()) {
			return -1n;
		}
		if (one.getPrice() < other.getPrice()) {
			return +1n;
		}
		if (one.getTimePlaced() < other.getTimePlaced()) {
			return -1n;
		}
		if (one.getTimePlaced() > other.getTimePlaced()) {
			return +1n;
		}
		return 0n;
	};
	
	public static def dump(orders:List[Order]) {
		for (order in orders) {
			Console.OUT.println(StringUtil.formatArray([
				"#BOOK", order.getMarket().getTime(), order.kind.id, order.getMarket().id, order.getPrice(), order.getVolume(),
				"", ""], " ", "", Int.MAX_VALUE));
		}
	}

	public def dump() {
		OrderBook.dump(this.ordersList.heap);
	}

	public def dump(comparator:(Order,Order)=>Int) {
		val orders = this.ordersList.heap.clone() as ArrayList[Order];
		orders.sort(comparator);
		OrderBook.dump(orders);
	}

	public def toList():List[Order] {
		return this.ordersList.heap.clone() as List[Order];
	}

	public static def main(Rail[String]) {
		val agent = new Agent(0);
		val market = new Market(0);
		val book = new OrderBook(HIGHERS_FIRST);
		book.add(new Order(Order.KIND_BUY_LIMIT_ORDER, agent, market, 100.0, 10, 30, 1));
		book.add(new Order(Order.KIND_BUY_LIMIT_ORDER, agent, market, 50.0, 10, 30, 2));
		book.add(new Order(Order.KIND_BUY_LIMIT_ORDER, agent, market, 50.0, 40, 30, 3));
		book.add(new Order(Order.KIND_BUY_LIMIT_ORDER, agent, market, 100.0, 10, 30, 4));
		book.add(new Order(Order.KIND_BUY_LIMIT_ORDER, agent, market, 70.0, 10, 30, 4));
		Console.OUT.println("The best: " + book.getBestPricedOrder());
		Console.OUT.println("Lowers-first");
		book.dump(LOWERS_FIRST);
		Console.OUT.println("Highers-first");
		book.dump(HIGHERS_FIRST);

		val h = new OrderBook(LOWERS_FIRST);
		h.ordersList.heap.addAll(book.ordersList.heap);
		h.ordersList.heapify();
		Console.OUT.println("The best: " + h.getBestPricedOrder());
		Console.OUT.println(h.ordersList.heap);
		while (h.ordersList.size() > 0) {
			Console.OUT.println(h.ordersList.pop());
		}
	}
}
