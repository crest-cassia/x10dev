package tekram.agent;
import x10.util.List;
import tekram.Agent;
import tekram.Market;
import tekram.Order;

public interface OrderMaking {
	
	public def decideOrders(agent:Agent, market:Market):List[Order];
}
