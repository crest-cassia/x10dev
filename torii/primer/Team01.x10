import x10.util.Team;

public class Team01 {

	public static def main(args:Rail[String]) {
		
		val N_PLACES = Place.numPlaces();
		Console.OUT.println("# N_PLACES " + N_PLACES);

		//val team = new Team(Place.places());
		val team = Team.WORLD;

//		Console.OUT.println("BEGIN Team.reduce()");
//		Console.OUT.println(team.reduce(here, 10000, Team.ADD));
//		Console.OUT.println("END Team.reduce()");

		finish {
			Console.OUT.println("BEGIN Team.allreduce()");
			for (p in Place.places()) {
				async {
		val a = new Rail[Long](N_PLACES * 1);
		val b = new Rail[Long](N_PLACES * 1);

					a(p.id) = p.id;
					//team.allreduce(a, 0, b, 0, a.size, Team.ADD);
					Console.OUT.println("HELLO at " + p.id + ", " + team.id());
					Console.OUT.println(b);
					Console.OUT.flush();
				}
			}
			Console.OUT.println("END Team.allreduce()");
		}
		team.barrier();
	}
}
