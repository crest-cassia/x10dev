struct InputParameters( beta: Double, h: Double, l: Long ) {

  public def toString(): String {
    return "{ \"beta\": " + beta + ", \"h\": " + h + " }";
  }
}
