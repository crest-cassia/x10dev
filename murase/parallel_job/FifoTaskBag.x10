import x10.glb.TaskBag;
import x10.util.ArrayList;

public class FifoTaskBag[T] implements TaskBag {
    
  val bag = new ArrayList[T]();
    
  public def size():Long=bag.size();
    
  public def merge(tb0:TaskBag): void {
    assert tb0 instanceof FifoTaskBag[T];
    val tb = tb0 as FifoTaskBag[T];
    bag.addAll(tb.bag);
  }

  public def split(): FifoTaskBag[T] {
    if (bag.size() <= 1) return null;
    val size = bag.size() / 2;
    val o = new FifoTaskBag[T]();
    for( i in 0..(size-1) ) {
      val t = bag.removeAt( i );
      o.bag.add( t );
    }
    return o;
  }
    
  public def bag()=bag;

  public static def main( args: Rail[String] ) {
    val b1 = new FifoTaskBag[Long]();

    for( i in 0..7 ) {
      b1.bag().add(i);
    }

    assert b1.size() == 8;
    p( b1.bag() );

    val b2 = b1.split();
    p( b1.bag() );  // [1,2,5,7]
    p( b2.bag() );  // [0,2,4,6]
    assert b1.size() == 4;
    assert b2.size() == 4;
    assert b2.bag()(0) == 0;
    assert b2.bag()(3) == 6;
    assert b1.bag()(0) == 1;
    assert b1.bag()(3) == 7;

    b2.merge(b1);
    p( b2.bag() );  // [0,2,4,6,1,3,5,7]
    assert b2.size() == 8;
  }

  private static def p( o: Any ) {
    Console.OUT.println( o );
  }
}
