import x10.util.Random;
import x10.util.Team;

public class Rail03 {
	
	public static def main(Rail[String]) {
		val random = new Random();
		val a = new Rail[Double](10, (Long) => random.nextDouble());
		
		val team = new Team(PlaceGroup.WORLD);
		
		Console.OUT.println(team.allreduce(9.0, Team.OR));
	}
}