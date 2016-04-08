
public class OpEq {
	
	var x:Rail[Long];
	var y:Long;

	def this() {
		this.x = new Rail[Long](100);
		this.y = 0;
	}

	def get(i:Long) = this.x(i);

	def set(i:Long, v:Long) = this.x(i) = v;

	def add(v:Long) = this.y += v;

	public static def main(Rail[String]) {
		val y = new OpEq();

		Console.OUT.println(y.get(3));
		y.set(3, 99);
		Console.OUT.println(y.get(3));

		Console.OUT.println(y.y);
		y.add(66);
		Console.OUT.println(y.y);
	}
}
