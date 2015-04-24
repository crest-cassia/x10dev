class Simulator {

  static def command( params: InputParameters, seed: Long ): String {
    return "../../build/ising2d.out " +
           (params.l-1) + " " +
           params.l + " " +
           params.beta + " " +
           params.h + " " +
           "10000 10000 " +
           seed;
  }
}

