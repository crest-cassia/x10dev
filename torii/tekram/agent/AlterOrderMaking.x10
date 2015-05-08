package tekram.agent;
import x10.util.List;
import x10.util.Set;
import tekram.Agent;
import tekram.Market;
import tekram.Order;

public interface AlterOrderMaking extends OrderMaking {
	
	public def decideOrders(agent:Agent, primary:Market, secondary:Market):List[Order];

	public def chooseAlternativeMarket(primary:Market, markets:Set[Market]):Market;
}
