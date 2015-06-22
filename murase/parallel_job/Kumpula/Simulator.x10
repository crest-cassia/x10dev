import x10.regionarray.Region;
import x10.io.File;

import x10.compiler.Native;
import x10.compiler.NativeCPPInclude;
import x10.compiler.NativeCPPCompilationUnit;

@NativeCPPInclude("main.hpp")
// @NativeCPPCompilationUnit("main.cpp")
// 
// @NativeCPPInclude("kumpula_2d_mobile_nd_ld_aging.hpp")
// @NativeCPPCompilationUnit("kumpula_2d_mobile_nd_ld_aging.cpp")
// @NativeCPPInclude("node_2d.hpp")
// @NativeCPPCompilationUnit("node_2d.cpp")
// @NativeCPPInclude("random.hpp")
// @NativeCPPCompilationUnit("random.cpp")

class Simulator {

  static struct InputParameters( aging: Double, p_ld: Double ) {
    public def toString(): String {
      return "{ \"aging\": " + aging + ", \"p_ld\": " + p_ld + " }";
    }

    public def toJson(): String {
      return toString();
    }
  }

  static struct OutputParameters( degree: Long ) {

    public def toString(): String {
      return "{ \"degree\": " + degree + " }";
    }

    public def normalize(): Rail[Double]{self.size==numOutputs} {
      val r = new Rail[Double](numOutputs);
      r(0) = (degree as Double) * 0.1;
      return r;
    }
  }

  static def run( params: InputParameters, seed: Long ): OutputParameters {
    // TODO: IMPLEMENT ME
    // System.sleep(1000);
    return OutputParameters( 100 );
  }

  public static val numParams = 2;
  public static val numOutputs = 1;

  static def deregularize( point: Point{self.rank==numParams} ): InputParameters {
    val aging = point(0) * 0.01;
    val p_ld  = point(1) * 0.001;
    return InputParameters( aging, p_ld );
  }

  static def searchRegion(): Region{self.rank==numParams} {
    return Region.makeRectangular( 80..100, 1..20 );
  }

}

