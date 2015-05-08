package tekram.util;
import x10.util.CollectionIterator;

/**
 * An unbounded priority {@linkplain Queue queue} based on a priority heap.
 * The elements of the priority queue are ordered according to their
 * {@linkplain Comparable natural ordering}, or by a {@link Comparator}
 * provided at queue construction time, depending on which constructor is
 * used.  A priority queue does not permit {@code null} elements.
 * A priority queue relying on natural ordering also does not permit
 * insertion of non-comparable objects (doing so may result in
 * {@code ClassCastException}).
 *
 * <p>The <em>head</em> of this queue is the <em>least</em> element
 * with respect to the specified ordering.  If multiple elements are
 * tied for least value, the head is one of those elements -- ties are
 * broken arbitrarily.  The queue retrieval operations {@code poll},
 * {@code remove}, {@code peek}, and {@code element} access the
 * element at the head of the queue.
 *
 * <p>A priority queue is unbounded, but has an internal
 * <i>capacity</i> governing the size of an array used to store the
 * elements on the queue.  It is always at least as large as the queue
 * size.  As elements are added to a priority queue, its capacity
 * grows automatically.  The details of the growth policy are not
 * specified.
 *
 * <p>This class and its iterator implement all of the
 * <em>optional</em> methods of the {@link Collection} and {@link
 * Iterator} interfaces.  The Iterator provided in method {@link
 * #iterator()} is <em>not</em> guaranteed to traverse the elements of
 * the priority queue in any particular order. If you need ordered
 * traversal, consider using {@code Arrays.sort(pq.toArray())}.
 *
 * <p> <strong>Note that this implementation is not synchronized.</strong>
 * Multiple threads should not access a {@code PriorityQueue}
 * instance concurrently if any of the threads modifies the queue.
 * Instead, use the thread-safe {@link
 * java.util.concurrent.PriorityBlockingQueue} class.
 *
 * <p>Implementation note: this implementation provides
 * O(log(n)) time for the enqueing and dequeing methods
 * ({@code offer}, {@code poll}, {@code remove()} and {@code add});
 * linear time for the {@code remove(Object)} and {@code contains(Object)}
 * methods; and constant time for the retrieval methods
 * ({@code peek}, {@code element}, and {@code size}).
 *
 * <p>This class is a member of the
 * <a href="{@docRoot}/../technotes/guides/collections/index.html">
 * Java Collections Framework</a>.
 *
 * @since 1.5
 * @author Josh Bloch, Doug Lea
 * @param <E> the type of elements held in this collection
 */
public class HeapQueue[E] {

    private static DEFAULT_INITIAL_CAPACITY = 11;

    /**
     * Priority queue represented as a balanced binary heap: the two
     * children of queue[n] are queue[2*n+1] and queue[2*(n+1)].  The
     * priority queue is ordered by comparator, or by the elements'
     * natural ordering, if comparator is null: For each node n in the
     * heap and each descendant d of n, n <= d.  The element with the
     * lowest value is in queue[0], assuming the queue is nonempty.
     */
    private transient var queue:Rail[Any];

    /**
     * The number of elements in the priority queue.
     */
    private var size:Long = 0;

    /**
     * The comparator, or null if priority queue uses elements'
     * natural ordering.
     */
    private var comparator:(E,E)=>Int;

    /**
     * The number of times this priority queue has been
     * <i>structurally modified</i>.  See AbstractList for gory details.
     */
    private transient var modCount:Long = 0;

    /**
     * Creates a {@code PriorityQueue} with the default initial
     * capacity (11) that orders its elements according to their
     * {@linkplain Comparable natural ordering}.
     */
    // public def this() {
    //     this(DEFAULT_INITIAL_CAPACITY, null);
    // }

    /**
     * Creates a {@code PriorityQueue} with the specified initial
     * capacity that orders its elements according to their
     * {@linkplain Comparable natural ordering}.
     *
     * @param initialCapacity the initial capacity for this priority queue
     * @throws IllegalArgumentException if {@code initialCapacity} is less
     *         than 1
     */
    // public def this(initialCapacity:Long) {
    //     this(initialCapacity, null);
    // }

    /**
     * Creates a {@code PriorityQueue} with the specified initial capacity
     * that orders its elements according to the specified comparator.
     *
     * @param  initialCapacity the initial capacity for this priority queue
     * @param  comparator the comparator that will be used to order this
     *         priority queue.  If {@code null}, the {@linkplain Comparable
     *         natural ordering} of the elements will be used.
     * @throws IllegalArgumentException if {@code initialCapacity} is
     *         less than 1
     */
    public def this(initialCapacity:Long, comparator:(E,E)=>Int) {
        assert initialCapacity >= 1;
        this.queue = new Rail[Any](initialCapacity);
        this.comparator = comparator;
    }
    public def this(comparator:(E,E)=>Int) {
    	this(DEFAULT_INITIAL_CAPACITY, comparator);
    }

    /**
     * Creates a {@code PriorityQueue} containing the elements in the
     * specified collection.  If the specified collection is an instance of
     * a {@link SortedSet} or is another {@code PriorityQueue}, this
     * priority queue will be ordered according to the same ordering.
     * Otherwise, this priority queue will be ordered according to the
     * {@linkplain Comparable natural ordering} of its elements.
     *
     * @param  c the collection whose elements are to be placed
     *         into this priority queue
     * @throws ClassCastException if elements of the specified collection
     *         cannot be compared to one another according to the priority
     *         queue's ordering
     * @throws NullPointerException if the specified collection or any
     *         of its elements are null
     */
    // @SuppressWarnings("unchecked")
    // public HeapQueue(Collection<? extends E> c) {
    //     if (c instanceof SortedSet<?>) {
    //         SortedSet<? extends E> ss = (SortedSet<? extends E>) c;
    //         this.comparator = (Comparator<? super E>) ss.comparator();
    //         initElementsFromCollection(ss);
    //     }
    //     else if (c instanceof MyPQ<?>) {
    //     	MyPQ<? extends E> pq = (MyPQ<? extends E>) c;
    //         this.comparator = (Comparator<? super E>) pq.comparator();
    //         initFromPriorityQueue(pq);
    //     }
    //     else {
    //         this.comparator = null;
    //         initFromCollection(c);
    //     }
    // }

    /**
     * Creates a {@code PriorityQueue} containing the elements in the
     * specified priority queue.  This priority queue will be
     * ordered according to the same ordering as the given priority
     * queue.
     *
     * @param  c the priority queue whose elements are to be placed
     *         into this priority queue
     * @throws ClassCastException if elements of {@code c} cannot be
     *         compared to one another according to {@code c}'s
     *         ordering
     * @throws NullPointerException if the specified priority queue or any
     *         of its elements are null
     */
    // @SuppressWarnings("unchecked")
    // public MyPQ(MyPQ<? extends E> c) {
    //     this.comparator = (Comparator<? super E>) c.comparator();
    //     initFromPriorityQueue(c);
    // }

    /**
     * Creates a {@code PriorityQueue} containing the elements in the
     * specified sorted set.   This priority queue will be ordered
     * according to the same ordering as the given sorted set.
     *
     * @param  c the sorted set whose elements are to be placed
     *         into this priority queue
     * @throws ClassCastException if elements of the specified sorted
     *         set cannot be compared to one another according to the
     *         sorted set's ordering
     * @throws NullPointerException if the specified sorted set or any
     *         of its elements are null
     */
    // @SuppressWarnings("unchecked")
    // public MyPQ(SortedSet<? extends E> c) {
    //     this.comparator = (Comparator<? super E>) c.comparator();
    //     initElementsFromCollection(c);
    // }

    // private void initFromPriorityQueue(MyPQ<? extends E> c) {
    //     if (c.getClass() == MyPQ.class) {
    //         this.queue = c.toArray();
    //         this.size = c.size();
    //     } else {
    //         initFromCollection(c);
    //     }
    // }

    // private void initElementsFromCollection(Collection<? extends E> c) {
    //     Object[] a = c.toArray();
    //     // If c.toArray incorrectly doesn't return Object[], copy it.
    //     if (a.getClass() != Object[].class)
    //         a = Arrays.copyOf(a, a.length, Object[].class);
    //     int len = a.length;
    //     if (len == 1 || this.comparator != null)
    //         for (int i = 0; i < len; i++)
    //             if (a[i] == null)
    //                 throw new NullPointerException();
    //     this.queue = a;
    //     this.size = a.length;
    // }

    /**
     * Initializes queue array with elements from the given Collection.
     *
     * @param c the collection
     */
    // private void initFromCollection(Collection<? extends E> c) {
    //     initElementsFromCollection(c);
    //     heapify();
    // }

    /**
     * The maximum size of array to allocate.
     * Some VMs reserve some header words in an array.
     * Attempts to allocate larger arrays may result in
     * OutOfMemoryError: Requested array size exceeds VM limit
     */
    private static MAX_ARRAY_SIZE = Int.MAX_VALUE - 8;

    /**
     * Increases the capacity of the array.
     *
     * @param minCapacity the desired minimum capacity
     */
    private def grow(minCapacity:Long) {
        var oldCapacity:Long = queue.size;
        // Double size if small; else grow by 50%
        var newCapacity:Long = oldCapacity + ((oldCapacity < 64) ?
                                         (oldCapacity + 2) :
                                         (oldCapacity >> 1));
        // overflow-conscious code
        if (newCapacity - MAX_ARRAY_SIZE > 0)
            newCapacity = hugeCapacity(minCapacity);
        val newQueue = new Rail[Any](newCapacity);
        Rail.copy(queue, 0, newQueue, 0, queue.size);
        queue = newQueue;
    }

    private static def hugeCapacity(minCapacity:Long):Long {
        if (minCapacity < 0) // overflow
        	throw new Error("OutOfMemoryError");
        return (minCapacity > MAX_ARRAY_SIZE) ?
            Int.MAX_VALUE + 0:
            MAX_ARRAY_SIZE;
    }

    /**
     * Inserts the specified element into this priority queue.
     *
     * @return {@code true} (as specified by {@link Collection#add})
     * @throws ClassCastException if the specified element cannot be
     *         compared with elements currently in this priority queue
     *         according to the priority queue's ordering
     * @throws NullPointerException if the specified element is null
     */
    public def add(e:E):Boolean {
        return push(e);
    }

    /**
     * Inserts the specified element into this priority queue.
     *
     * @return {@code true} (as specified by {@link Queue#offer})
     * @throws ClassCastException if the specified element cannot be
     *         compared with elements currently in this priority queue
     *         according to the priority queue's ordering
     * @throws NullPointerException if the specified element is null
     */
    public def push(e:E):Boolean {
        if (e == null)
            throw new NullPointerException();
        modCount++;
        val i = size;
        if (i >= queue.size)
            grow(i + 1);
        size = i + 1;
        if (i == 0)
            queue(0) = e;
        else
            siftUp(i, e);
        return true;
    }

    public def peek():E {
        if (size == 0)
            throw new ArrayIndexOutOfBoundsException();
        return queue(0) as E;
    }

    private def indexOf(o:Any):Long {
        if (o != null) {
            for (var i:Long = 0; i < size; i++)
                if (o.equals(queue(i)))
                    return i;
        }
        return -1;
    }

    /**
     * Removes a single instance of the specified element from this queue,
     * if it is present.  More formally, removes an element {@code e} such
     * that {@code o.equals(e)}, if this queue contains one or more such
     * elements.  Returns {@code true} if and only if this queue contained
     * the specified element (or equivalently, if this queue changed as a
     * result of the call).
     *
     * @param o element to be removed from this queue, if present
     * @return {@code true} if this queue changed as a result of the call
     */
    public def remove(o:Any):Boolean {
        val i = indexOf(o);
        if (i == -1)
            return false;
        else {
            removeAt(i);
            return true;
        }
    }

    /**
     * Version of remove using reference equality, not equals.
     * Needed by iterator.remove.
     *
     * @param o element to be removed from this queue, if present
     * @return {@code true} if removed
     */
    def removeEq(o:Any):Boolean {
        for (var i:Long = 0; i < size; i++) {
            if (o == queue(i)) {
                removeAt(i);
                return true;
            }
        }
        return false;
    }

    /**
     * Returns {@code true} if this queue contains the specified element.
     * More formally, returns {@code true} if and only if this queue contains
     * at least one element {@code e} such that {@code o.equals(e)}.
     *
     * @param o object to be checked for containment in this queue
     * @return {@code true} if this queue contains the specified element
     */
    public def contains(o:Any):Boolean {
        return indexOf(o) != -1;
    }

    // /**
    //  * Returns an array containing all of the elements in this queue.
    //  * The elements are in no particular order.
    //  *
    //  * <p>The returned array will be "safe" in that no references to it are
    //  * maintained by this queue.  (In other words, this method must allocate
    //  * a new array).  The caller is thus free to modify the returned array.
    //  *
    //  * <p>This method acts as bridge between array-based and collection-based
    //  * APIs.
    //  *
    //  * @return an array containing all of the elements in this queue
    //  */
    // public Object[] toArray() {
    //     return Arrays.copyOf(queue, size);
    // }

    // /**
    //  * Returns an array containing all of the elements in this queue; the
    //  * runtime type of the returned array is that of the specified array.
    //  * The returned array elements are in no particular order.
    //  * If the queue fits in the specified array, it is returned therein.
    //  * Otherwise, a new array is allocated with the runtime type of the
    //  * specified array and the size of this queue.
    //  *
    //  * <p>If the queue fits in the specified array with room to spare
    //  * (i.e., the array has more elements than the queue), the element in
    //  * the array immediately following the end of the collection is set to
    //  * {@code null}.
    //  *
    //  * <p>Like the {@link #toArray()} method, this method acts as bridge between
    //  * array-based and collection-based APIs.  Further, this method allows
    //  * precise control over the runtime type of the output array, and may,
    //  * under certain circumstances, be used to save allocation costs.
    //  *
    //  * <p>Suppose <tt>x</tt> is a queue known to contain only strings.
    //  * The following code can be used to dump the queue into a newly
    //  * allocated array of <tt>String</tt>:
    //  *
    //  * <pre>
    //  *     String[] y = x.toArray(new String[0]);</pre>
    //  *
    //  * Note that <tt>toArray(new Object[0])</tt> is identical in function to
    //  * <tt>toArray()</tt>.
    //  *
    //  * @param a the array into which the elements of the queue are to
    //  *          be stored, if it is big enough; otherwise, a new array of the
    //  *          same runtime type is allocated for this purpose.
    //  * @return an array containing all of the elements in this queue
    //  * @throws ArrayStoreException if the runtime type of the specified array
    //  *         is not a supertype of the runtime type of every element in
    //  *         this queue
    //  * @throws NullPointerException if the specified array is null
    //  */
    // public <T> T[] toArray(T[] a) {
    //     if (a.length < size)
    //         // Make a new array of a's runtime type, but my contents:
    //         return (T[]) Arrays.copyOf(queue, size, a.getClass());
    //     System.arraycopy(queue, 0, a, 0, size);
    //     if (a.length > size)
    //         a[size] = null;
    //     return a;
    // }

    /**
     * Returns an iterator over the elements in this queue. The iterator
     * does not return the elements in any particular order.
     *
     * @return an iterator over the elements in this queue
     */
    public def iterator():CollectionIterator[E] {
        return new Itr();
    }

    private final class Itr implements CollectionIterator[E] {
        /**
         * Index (into queue array) of element to be returned by
         * subsequent call to next.
         */
        private var cursor:Long = 0;

        /**
         * Index of element returned by most recent call to next,
         * unless that element came from the forgetMeNot list.
         * Set to -1 if element is deleted by a call to remove.
         */
        private var lastRet:Long = -1;

        /**
         * A queue of elements that were moved from the unvisited portion of
         * the heap into the visited portion as a result of "unlucky" element
         * removals during the iteration.  (Unlucky element removals are those
         * that require a siftup instead of a siftdown.)  We must visit all of
         * the elements in this list to complete the iteration.  We do this
         * after we've completed the "normal" iteration.
         *
         * We expect that most iterations, even those involving removals,
         * will not need to store elements in this field.
         */
        private var forgetMeNot:Deque = null;

        /**
         * Element returned by the most recent call to next iff that
         * element was drawn from the forgetMeNot list.
         */
        private var lastRetElt:Any = null;

        /**
         * The modCount value that the iterator believes that the backing
         * Queue should have.  If this expectation is violated, the iterator
         * has detected concurrent modification.
         */
        private var expectedModCount:Long = modCount;

        public def hasNext():Boolean {
            return cursor < size ||
                (forgetMeNot != null && forgetMeNot.size() > 0);
        }

        public def next():E {
            if (expectedModCount != modCount)
                throw new Exception("ConcurrentModificationException");
            if (cursor < size)
                return queue(lastRet = cursor++) as E;
            if (forgetMeNot != null) {
                lastRet = -1;
                lastRetElt = forgetMeNot.poll() as E;
                if (lastRetElt != null)
                    return lastRetElt as E;
            }
            throw new Exception("NoSuchElementException");
        }

        public def remove() {
            if (expectedModCount != modCount)
                throw new Exception("ConcurrentModificationException");
            if (lastRet != -1) {
                val moved = HeapQueue.this.removeAt(lastRet);
                lastRet = -1;
                if (moved == null)
                    cursor--;
                else {
                    if (forgetMeNot == null)
                        forgetMeNot = new Deque();
                    forgetMeNot.push(moved);
                }
            } else if (lastRetElt != null) {
            	HeapQueue.this.removeEq(lastRetElt);
                lastRetElt = null;
            } else {
                throw new IllegalStateException();
            }
            expectedModCount = modCount;
        }
    }

    public def size():Long {
        return size;
    }

    /**
     * Removes all of the elements from this priority queue.
     * The queue will be empty after this call returns.
     */
    public def clear() {
        modCount++;
        for (var i:Long = 0; i < size; i++)
            queue(i) = null;
        size = 0;
    }

    public def poll():E {
        if (size == 0)
            throw new NullPointerException();
        val s = --size;
        modCount++;
        val result = queue(0) as E;
        val x = queue(s) as E;
        queue(s) = null;
        if (s != 0)
            siftDown(0, x);
        return result;
    }

    /**
     * Removes the ith element from queue.
     *
     * Normally this method leaves the elements at up to i-1,
     * inclusive, untouched.  Under these circumstances, it returns
     * null.  Occasionally, in order to maintain the heap invariant,
     * it must swap a later element of the list with one earlier than
     * i.  Under these circumstances, this method returns the element
     * that was previously at the end of the list and is now at some
     * position before i. This fact is used by iterator.remove so as to
     * avoid missing traversing elements.
     */
    private def removeAt(i:Long):Any {
        assert i >= 0 && i < size;
        modCount++;
        val s = --size;
        if (s == i) // removed last element
            queue(i) = null;
        else {
            val moved = queue(s) as E;
            queue(s) = null;
            siftDown(i, moved);
            if (queue(i) == moved) {
                siftUp(i, moved);
                if (queue(i) != moved)
                    return moved;
            }
        }
        return null;
    }

    /**
     * Inserts item x at position k, maintaining heap invariant by
     * promoting x up the tree until it is greater than or equal to
     * its parent, or is the root.
     *
     * To simplify and speed up coercions and comparisons. the
     * Comparable and Comparator versions are separated into different
     * methods that are otherwise identical. (Similarly for siftDown.)
     *
     * @param k the position to fill
     * @param x the item to insert
     */
    private def siftUp(k:Long, x:E) {
        siftUpUsingComparator(k, x);
    }
    // private def siftUp(k:Long, x:Comparable[E]) {
    // 	siftUpComparable(k, x);
    // }

    // private def siftUpComparable(_k:Long, key:Comparable[E]) {
    // 	var k:Long = _k;
    //     while (k > 0) {
    //         val parent = (k - 1) >>> 1;
    //         val e = queue(parent);
    //         if (key.compareTo(e as E) >= 0)
    //             break;
    //         queue(k) = e;
    //         k = parent;
    //     }
    //     queue(k) = key;
    // }

    private def siftUpUsingComparator(_k:Long, x:E) {
    	var k:Long = _k;
        while (k > 0) {
            val parent = (k - 1) >>> 1;
            val e = queue(parent);
            if (comparator(x, e as E) >= 0)
                break;
            queue(k) = e;
            k = parent;
        }
        queue(k) = x;
    }

    /**
     * Inserts item x at position k, maintaining heap invariant by
     * demoting x down the tree repeatedly until it is less than or
     * equal to its children or is a leaf.
     *
     * @param k the position to fill
     * @param x the item to insert
     */
    private def siftDown(k:Long, x:E) {
        siftDownUsingComparator(k, x);
    }
    // private def siftDown(k:Long, x:Comparable[E]) {
    // 	siftDownComparable(k, x);
    // }
    
    // private def siftDownComparable(_k:Long, key:Comparable[E]) {
    // 	var k:Long = _k;
    //     val half = size >>> 1;        // loop while a non-leaf
    //     while (k < half) {
    //         var child:Long = (k << 1) + 1; // assume left child is least
    //         var c:Any = queue(child);
    //         val right = child + 1;
    //         if (right < size &&
    //             (c as Comparable[E]).compareTo(queue(right) as E) > 0)
    //             c = queue(child = right);
    //         if (key.compareTo(c as E) <= 0)
    //             break;
    //         queue(k) = c;
    //         k = child;
    //     }
    //     queue(k) = key;
    // }

    private def siftDownUsingComparator(_k:Long, x:E) {
    	var k:Long = _k;
        val half = size >>> 1;
        while (k < half) {
            var child:Long = (k << 1) + 1;
            var c:Any = queue(child);
            val right = child + 1;
            if (right < size &&
                comparator(c as E, queue(right) as E) > 0)
                c = queue(child = right);
            if (comparator(x, c as E) <= 0)
                break;
            queue(k) = c;
            k = child;
        }
        queue(k) = x;
    }

    /**
     * Establishes the heap invariant (described above) in the entire tree,
     * assuming nothing about the order of the elements prior to the call.
     */
    private def heapify() {
        for (var i:Long = (size >>> 1) - 1; i >= 0; i--)
            siftDown(i, queue(i) as E);
    }
}
