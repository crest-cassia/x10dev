class Simulator {

  static def command( params: InputParameters, seed: Long ): String {
    return "../../build/ising2d.out 99 100 " +
           params.beta + " " + params.h + " 10000 10000 " + seed;
  }
}
