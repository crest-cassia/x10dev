import x10.regionarray.Region;

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

  public static val numParams = 2;

  static def deregularize( point: Point{self.rank==numParams} ): InputParameters {
    val beta = point(0) * 0.01;
    val h    = point(1) * 0.01;
    val lx   = 100;
    return InputParameters( beta, h, lx );
  }

  static def searchRegion(): Region{self.rank==numParams} {
    return Region.makeRectangular( 20..50, -100..100 );
  }
}

