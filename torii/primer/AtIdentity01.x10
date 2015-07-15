
public class AtIdentity01 {

	static class X {

		static struct Item(id:String) {};
		static ITEM_A = new Item("A");
		static ITEM_B = new Item("B");

		public var item:Item;

		public def this(item:Item) {
			this.item = item;
		}
	}

	public static def main(Rail[String]) {
		
		val x = new X(X.ITEM_A);
		Console.OUT.println(x.item == X.ITEM_A); // This is true.
		Console.OUT.println(x.item.id.equals(X.ITEM_A.id)); // This is true.

		val y = at (here) { return new X(X.ITEM_A); };
		Console.OUT.println(y.item == X.ITEM_A); // This is false!!!
		Console.OUT.println(y.item.id.equals(X.ITEM_A.id)); // This is true.
	}
}
