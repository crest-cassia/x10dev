public class Enum02 {
	
	// A classic Java hack: Type-safe enum.
	static struct Suit(id:String) {
		public static SUIT_HEART = Suit("HEART");
		public static SUIT_DIAMOND = Suit("DIAMOND");
		public static SUIT_CLUB = Suit("CLUB");
		public static SUIT_SPADE = Suit("SPADE");
	}

	public static def main(Rail[String]) {
		Console.OUT.println(Suit.SUIT_HEART);
		var suit:Suit = Suit.SUIT_HEART;
		
		if (suit == Suit.SUIT_HEART) {
			Console.OUT.println("It's HEART");
		} else {
			Console.OUT.println("It's not HEART");
		}
	}
}
