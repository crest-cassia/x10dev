/*************************************************/
/* START of StaticTasks */
#include <StaticTasks.h>

#include <x10/lang/Long.h>
#include <x10/lang/Fun_0_0.h>
#include <StaticTasks__MyTaskQueue.h>
#include <x10/glb/GLB.h>
#include <x10/glb/GLBParameters.h>
#include <x10/io/Printer.h>
#include <x10/io/Console.h>
#include <x10/lang/Any.h>
#include <x10/lang/VoidFun_0_0.h>
#include <x10/lang/Rail.h>
#include <x10/lang/String.h>
#include <x10/lang/Boolean.h>
#include <x10/compiler/Synthetic.h>
#include <x10/lang/String.h>
#ifndef STATICTASKS__CLOSURE__1_CLOSURE
#define STATICTASKS__CLOSURE__1_CLOSURE
#include <x10/lang/Closure.h>
#include <x10/lang/Fun_0_0.h>
class StaticTasks__closure__1 : public ::x10::lang::Closure {
    public:
    
    static ::x10::lang::Fun_0_0< ::StaticTasks__MyTaskQueue*>::itable<StaticTasks__closure__1> _itable;
    static ::x10aux::itable_entry _itables[2];
    
    virtual ::x10aux::itable_entry* _getITables() { return _itables; }
    
    ::StaticTasks__MyTaskQueue* __apply(){
        return ::StaticTasks__MyTaskQueue::_make(saved_this);
        
    }
    
    // captured environment
    ::StaticTasks* saved_this;
    
    ::x10aux::serialization_id_t _get_serialization_id() {
        return _serialization_id;
    }
    
    void _serialize_body(::x10aux::serialization_buffer &buf) {
        buf.write(this->saved_this);
    }
    
    static x10::lang::Reference* _deserialize(::x10aux::deserialization_buffer &buf) {
        StaticTasks__closure__1* storage = ::x10aux::alloc_z<StaticTasks__closure__1>();
        buf.record_reference(storage);
        ::StaticTasks* that_saved_this = buf.read< ::StaticTasks*>();
        StaticTasks__closure__1* this_ = new (storage) StaticTasks__closure__1(that_saved_this);
        return this_;
    }
    
    StaticTasks__closure__1(::StaticTasks* saved_this) : saved_this(saved_this) { }
    
    static const ::x10aux::serialization_id_t _serialization_id;
    
    static const ::x10aux::RuntimeType* getRTT() { return ::x10aux::getRTT< ::x10::lang::Fun_0_0< ::StaticTasks__MyTaskQueue*> >(); }
    virtual const ::x10aux::RuntimeType *_type() const { return ::x10aux::getRTT< ::x10::lang::Fun_0_0< ::StaticTasks__MyTaskQueue*> >(); }
    
    const char* toNativeString() {
        return "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10:85";
    }

};

#endif // STATICTASKS__CLOSURE__1_CLOSURE
#ifndef STATICTASKS__CLOSURE__2_CLOSURE
#define STATICTASKS__CLOSURE__2_CLOSURE
#include <x10/lang/Closure.h>
#include <x10/lang/VoidFun_0_0.h>
class StaticTasks__closure__2 : public ::x10::lang::Closure {
    public:
    
    static ::x10::lang::VoidFun_0_0::itable<StaticTasks__closure__2> _itable;
    static ::x10aux::itable_entry _itables[2];
    
    virtual ::x10aux::itable_entry* _getITables() { return _itables; }
    
    void __apply(){
        ::x10aux::nullCheck(glb->x10::glb::GLB< ::StaticTasks__MyTaskQueue*, x10_long>::taskQueue())->init(
          n);
    }
    
    // captured environment
    ::x10::glb::GLB< ::StaticTasks__MyTaskQueue*, x10_long>* glb;
    x10_long n;
    
    ::x10aux::serialization_id_t _get_serialization_id() {
        return _serialization_id;
    }
    
    void _serialize_body(::x10aux::serialization_buffer &buf) {
        buf.write(this->glb);
        buf.write(this->n);
    }
    
    static x10::lang::Reference* _deserialize(::x10aux::deserialization_buffer &buf) {
        StaticTasks__closure__2* storage = ::x10aux::alloc_z<StaticTasks__closure__2>();
        buf.record_reference(storage);
        ::x10::glb::GLB< ::StaticTasks__MyTaskQueue*, x10_long>* that_glb = buf.read< ::x10::glb::GLB< ::StaticTasks__MyTaskQueue*, x10_long>*>();
        x10_long that_n = buf.read<x10_long>();
        StaticTasks__closure__2* this_ = new (storage) StaticTasks__closure__2(that_glb, that_n);
        return this_;
    }
    
    StaticTasks__closure__2(::x10::glb::GLB< ::StaticTasks__MyTaskQueue*, x10_long>* glb, x10_long n) : glb(glb), n(n) { }
    
    static const ::x10aux::serialization_id_t _serialization_id;
    
    static const ::x10aux::RuntimeType* getRTT() { return ::x10aux::getRTT< ::x10::lang::VoidFun_0_0>(); }
    virtual const ::x10aux::RuntimeType *_type() const { return ::x10aux::getRTT< ::x10::lang::VoidFun_0_0>(); }
    
    const char* toNativeString() {
        return "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10:89";
    }

};

#endif // STATICTASKS__CLOSURE__2_CLOSURE

//#line 84 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
void StaticTasks::run(x10_long n) {
    
    //#line 85 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    ::x10::lang::Fun_0_0< ::StaticTasks__MyTaskQueue*>* init = reinterpret_cast< ::x10::lang::Fun_0_0< ::StaticTasks__MyTaskQueue*>*>((new (::x10aux::alloc< ::x10::lang::Fun_0_0< ::StaticTasks__MyTaskQueue*> >(sizeof(StaticTasks__closure__1)))StaticTasks__closure__1(this)));
    
    //#line 86 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    ::x10::glb::GLB< ::StaticTasks__MyTaskQueue*, x10_long>* glb = ::x10::glb::GLB< ::StaticTasks__MyTaskQueue*, x10_long>::_make(init,
                                                                                                                                  ::x10::glb::GLBParameters::FMGL(Default__get)(),
                                                                                                                                  true);
    
    //#line 88 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    ::x10::io::Console::FMGL(OUT__get)()->x10::io::Printer::println(
      reinterpret_cast< ::x10::lang::Any*>((&::StaticTasks_Strings::sl__663)));
    
    //#line 89 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    ::x10::lang::VoidFun_0_0* start = reinterpret_cast< ::x10::lang::VoidFun_0_0*>((new (::x10aux::alloc< ::x10::lang::VoidFun_0_0>(sizeof(StaticTasks__closure__2)))StaticTasks__closure__2(glb, n)));
    
    //#line 90 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    ::x10::lang::Rail< x10_long >* r = glb->x10::glb::GLB< ::StaticTasks__MyTaskQueue*, x10_long>::run(
                                         start);
    
    //#line 91 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    ::x10::io::Console::FMGL(OUT__get)()->x10::io::Printer::println(
      reinterpret_cast< ::x10::lang::Any*>(r));
}

//#line 94 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
void StaticTasks::main(::x10::lang::Rail< ::x10::lang::String* >* args) {
    
    //#line 95 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    x10_long n = (((x10_long)(::x10aux::nullCheck(args)->FMGL(size))) < (((x10_long)1ll)))
      ? (((x10_long)10ll)) : (::x10::lang::LongNatives::parseLong(::x10aux::nullCheck(args)->x10::lang::Rail< ::x10::lang::String* >::__apply(
                                                                    ((x10_long)0ll))));
    
    //#line 96 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    ::StaticTasks* o = ::StaticTasks::_make();
    
    //#line 97 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    o->run(n);
}

//#line 12 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
::StaticTasks* StaticTasks::StaticTasks____this__StaticTasks(
  ) {
    return this;
    
}
void StaticTasks::_constructor() {
    this->StaticTasks::__fieldInitializers_StaticTasks();
}
::StaticTasks* StaticTasks::_make() {
    ::StaticTasks* this_ = new (::x10aux::alloc_z< ::StaticTasks>()) ::StaticTasks();
    this_->_constructor();
    return this_;
}


void StaticTasks::__fieldInitializers_StaticTasks() {
 
}
const ::x10aux::serialization_id_t StaticTasks::_serialization_id = 
    ::x10aux::DeserializationDispatcher::addDeserializer(::StaticTasks::_deserializer);

void StaticTasks::_serialize_body(::x10aux::serialization_buffer& buf) {
    
}

::x10::lang::Reference* ::StaticTasks::_deserializer(::x10aux::deserialization_buffer& buf) {
    ::StaticTasks* this_ = new (::x10aux::alloc_z< ::StaticTasks>()) ::StaticTasks();
    buf.record_reference(this_);
    this_->_deserialize_body(buf);
    return this_;
}

void StaticTasks::_deserialize_body(::x10aux::deserialization_buffer& buf) {
    
}

::x10aux::RuntimeType StaticTasks::rtt;
void StaticTasks::_initRTT() {
    if (rtt.initStageOne(&rtt)) return;
    const ::x10aux::RuntimeType** parents = NULL; 
    rtt.initStageTwo("StaticTasks",::x10aux::RuntimeType::class_kind, 0, parents, 0, NULL, NULL);
}

::x10::lang::String StaticTasks_Strings::sl__663("Starting...");

::x10::lang::Fun_0_0< ::StaticTasks__MyTaskQueue*>::itable<StaticTasks__closure__1>StaticTasks__closure__1::_itable(&::x10::lang::Reference::equals, &::x10::lang::Closure::hashCode, &StaticTasks__closure__1::__apply, &StaticTasks__closure__1::toString, &::x10::lang::Closure::typeName);
::x10aux::itable_entry StaticTasks__closure__1::_itables[2] = {::x10aux::itable_entry(&::x10aux::getRTT< ::x10::lang::Fun_0_0< ::StaticTasks__MyTaskQueue*> >, &StaticTasks__closure__1::_itable),::x10aux::itable_entry(NULL, NULL)};

const ::x10aux::serialization_id_t StaticTasks__closure__1::_serialization_id = 
    ::x10aux::DeserializationDispatcher::addDeserializer(StaticTasks__closure__1::_deserialize);

::x10::lang::VoidFun_0_0::itable<StaticTasks__closure__2>StaticTasks__closure__2::_itable(&::x10::lang::Reference::equals, &::x10::lang::Closure::hashCode, &StaticTasks__closure__2::__apply, &StaticTasks__closure__2::toString, &::x10::lang::Closure::typeName);
::x10aux::itable_entry StaticTasks__closure__2::_itables[2] = {::x10aux::itable_entry(&::x10aux::getRTT< ::x10::lang::VoidFun_0_0>, &StaticTasks__closure__2::_itable),::x10aux::itable_entry(NULL, NULL)};

const ::x10aux::serialization_id_t StaticTasks__closure__2::_serialization_id = 
    ::x10aux::DeserializationDispatcher::addDeserializer(StaticTasks__closure__2::_deserialize);

/* END of StaticTasks */
/*************************************************/
/*************************************************/
/* START of StaticTasks$MyTaskQueue$MyResult */
#include <StaticTasks__MyTaskQueue__MyResult.h>

#include <x10/glb/GLBResult.h>
#include <x10/lang/Long.h>
#include <StaticTasks__MyTaskQueue.h>
#include <x10/io/Printer.h>
#include <x10/io/Console.h>
#include <x10/lang/Any.h>
#include <x10/lang/Rail.h>
#include <x10/lang/String.h>
#include <x10/lang/Runtime.h>
#include <x10/lang/Place.h>
#include <x10/lang/Int.h>
#include <x10/util/Team.h>
#include <x10/compiler/Synthetic.h>
#include <StaticTasks.h>
#include <x10/lang/String.h>

//#line 14 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"

//#line 60 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"

//#line 62 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
void StaticTasks__MyTaskQueue__MyResult::_constructor(::StaticTasks__MyTaskQueue* out__,
                                                      x10_long local_result) {
    (this)->::x10::glb::GLBResult<x10_long>::_constructor();
    
    //#line 14 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    this->FMGL(out__) = out__;
    
    //#line 62 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    
    //#line 59 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    this->StaticTasks__MyTaskQueue__MyResult::__fieldInitializers_StaticTasks_MyTaskQueue_MyResult();
    
    //#line 63 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    ::x10::io::Console::FMGL(OUT__get)()->x10::io::Printer::println(
      reinterpret_cast< ::x10::lang::Any*>((&::StaticTasks__MyTaskQueue__MyResult_Strings::sl__665)));
    
    //#line 64 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    this->FMGL(result) = local_result;
}
::StaticTasks__MyTaskQueue__MyResult* StaticTasks__MyTaskQueue__MyResult::_make(
  ::StaticTasks__MyTaskQueue* out__, x10_long local_result) {
    ::StaticTasks__MyTaskQueue__MyResult* this_ = new (::x10aux::alloc_z< ::StaticTasks__MyTaskQueue__MyResult>()) ::StaticTasks__MyTaskQueue__MyResult();
    this_->_constructor(out__, local_result);
    return this_;
}



//#line 67 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
::x10::lang::Rail< x10_long >* StaticTasks__MyTaskQueue__MyResult::getResult(
  ) {
    
    //#line 68 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    ::x10::lang::Rail< x10_long >* r = ::x10::lang::Rail< x10_long >::_make(((x10_long)1ll));
    
    //#line 69 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    r->x10::lang::Rail< x10_long >::__set(((x10_long)0ll), this->FMGL(result));
    
    //#line 70 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    ::x10::io::Console::FMGL(OUT__get)()->x10::io::Printer::println(
      reinterpret_cast< ::x10::lang::Any*>(::x10::lang::String::__plus(::x10::lang::String::__plus(::x10::lang::String::__plus((&::StaticTasks__MyTaskQueue__MyResult_Strings::sl__666), ::x10::lang::Place::_make(::x10aux::here)), (&::StaticTasks__MyTaskQueue__MyResult_Strings::sl__667)), r)));
    
    //#line 71 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    return r;
    
}

//#line 74 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
x10_int StaticTasks__MyTaskQueue__MyResult::getReduceOperator() {
    
    //#line 75 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    return ::x10::util::Team::FMGL(ADD__get)();
    
}

//#line 78 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
void StaticTasks__MyTaskQueue__MyResult::display(::x10::lang::Rail< x10_long >* r) {
    
    //#line 79 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    ::x10::io::Console::FMGL(OUT__get)()->x10::io::Printer::println(
      reinterpret_cast< ::x10::lang::Any*>(::x10::lang::String::__plus((&::StaticTasks__MyTaskQueue__MyResult_Strings::sl__668), ::x10aux::nullCheck(r)->x10::lang::Rail< x10_long >::__apply(
                                                                                                                                   ((x10_long)0ll)))));
}

//#line 59 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
::StaticTasks__MyTaskQueue__MyResult* StaticTasks__MyTaskQueue__MyResult::StaticTasks__MyTaskQueue__MyResult____this__StaticTasks__MyTaskQueue__MyResult(
  ) {
    return this;
    
}
::StaticTasks__MyTaskQueue* StaticTasks__MyTaskQueue__MyResult::StaticTasks__MyTaskQueue__MyResult____this__StaticTasks__MyTaskQueue(
  ) {
    return this->FMGL(out__);
    
}
::StaticTasks* StaticTasks__MyTaskQueue__MyResult::StaticTasks__MyTaskQueue__MyResult____this__StaticTasks(
  ) {
    return ::x10aux::nullCheck(this->FMGL(out__))->FMGL(out__);
    
}
void StaticTasks__MyTaskQueue__MyResult::__fieldInitializers_StaticTasks_MyTaskQueue_MyResult(
  ) {
 
}
const ::x10aux::serialization_id_t StaticTasks__MyTaskQueue__MyResult::_serialization_id = 
    ::x10aux::DeserializationDispatcher::addDeserializer(::StaticTasks__MyTaskQueue__MyResult::_deserializer);

void StaticTasks__MyTaskQueue__MyResult::_serialize_body(::x10aux::serialization_buffer& buf) {
    ::x10::glb::GLBResult<x10_long>::_serialize_body(buf);
    buf.write(this->FMGL(result));
    buf.write(this->FMGL(out__));
    
}

::x10::lang::Reference* ::StaticTasks__MyTaskQueue__MyResult::_deserializer(::x10aux::deserialization_buffer& buf) {
    ::StaticTasks__MyTaskQueue__MyResult* this_ = new (::x10aux::alloc_z< ::StaticTasks__MyTaskQueue__MyResult>()) ::StaticTasks__MyTaskQueue__MyResult();
    buf.record_reference(this_);
    this_->_deserialize_body(buf);
    return this_;
}

void StaticTasks__MyTaskQueue__MyResult::_deserialize_body(::x10aux::deserialization_buffer& buf) {
    ::x10::glb::GLBResult<x10_long>::_deserialize_body(buf);
    FMGL(result) = buf.read<x10_long>();
    FMGL(out__) = buf.read< ::StaticTasks__MyTaskQueue*>();
}

::x10aux::RuntimeType StaticTasks__MyTaskQueue__MyResult::rtt;
void StaticTasks__MyTaskQueue__MyResult::_initRTT() {
    if (rtt.initStageOne(&rtt)) return;
    const ::x10aux::RuntimeType* parents[1] = { ::x10aux::getRTT< ::x10::glb::GLBResult<x10_long> >()};
    rtt.initStageTwo("StaticTasks.MyTaskQueue.MyResult",::x10aux::RuntimeType::class_kind, 1, parents, 0, NULL, NULL);
}

::x10::lang::String StaticTasks__MyTaskQueue__MyResult_Strings::sl__667(" : ");
::x10::lang::String StaticTasks__MyTaskQueue__MyResult_Strings::sl__665("constructor of MyResult");
::x10::lang::String StaticTasks__MyTaskQueue__MyResult_Strings::sl__668("MyResult#display: ");
::x10::lang::String StaticTasks__MyTaskQueue__MyResult_Strings::sl__666("MyResult#getResult at ");

/* END of StaticTasks$MyTaskQueue$MyResult */
/*************************************************/
/*************************************************/
/* START of StaticTasks$MyTaskQueue */
#include <StaticTasks__MyTaskQueue.h>

#include <x10/glb/TaskQueue.h>
#include <x10/lang/Long.h>
#include <StaticTasks.h>
#include <x10/glb/ArrayListTaskBag.h>
#include <x10/io/Printer.h>
#include <x10/io/Console.h>
#include <x10/lang/Any.h>
#include <x10/lang/String.h>
#include <x10/lang/Runtime.h>
#include <x10/lang/Place.h>
#include <x10/lang/Boolean.h>
#include <x10/util/ArrayList.h>
#include <x10/glb/Context.h>
#include <x10/glb/TaskBag.h>
#include <StaticTasks__MyTaskQueue__MyResult.h>
#include <x10/compiler/Synthetic.h>
#include <x10/lang/String.h>
::x10::glb::TaskQueue< ::StaticTasks__MyTaskQueue*, x10_long>::itable< ::StaticTasks__MyTaskQueue >  StaticTasks__MyTaskQueue::_itable_0(&StaticTasks__MyTaskQueue::count, &::x10::lang::X10Class::equals, &StaticTasks__MyTaskQueue::getResult, &::x10::lang::X10Class::hashCode, &StaticTasks__MyTaskQueue::merge, &StaticTasks__MyTaskQueue::printLog, &StaticTasks__MyTaskQueue::process, &StaticTasks__MyTaskQueue::split, &::x10::lang::X10Class::toString, &::x10::lang::X10Class::typeName);
::x10::lang::Any::itable< ::StaticTasks__MyTaskQueue >  StaticTasks__MyTaskQueue::_itable_1(&::x10::lang::X10Class::equals, &::x10::lang::X10Class::hashCode, &::x10::lang::X10Class::toString, &::x10::lang::X10Class::typeName);
::x10aux::itable_entry StaticTasks__MyTaskQueue::_itables[3] = {::x10aux::itable_entry(&::x10aux::getRTT< ::x10::glb::TaskQueue< ::StaticTasks__MyTaskQueue*, x10_long> >, &_itable_0), ::x10aux::itable_entry(&::x10aux::getRTT< ::x10::lang::Any>, &_itable_1), ::x10aux::itable_entry(NULL, (void*)"::StaticTasks__MyTaskQueue")};

//#line 12 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"

//#line 15 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"

//#line 16 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"

//#line 18 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
void StaticTasks__MyTaskQueue::init(x10_long n) {
    
    //#line 19 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    ::x10::io::Console::FMGL(OUT__get)()->x10::io::Printer::println(reinterpret_cast< ::x10::lang::Any*>(::x10::lang::String::__plus(::x10::lang::String::__plus(::x10::lang::String::__plus((&::StaticTasks__MyTaskQueue_Strings::sl__670), n), (&::StaticTasks__MyTaskQueue_Strings::sl__671)), ::x10::lang::Place::_make(::x10aux::here))));
    
    //#line 20 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    x10_long i__642min__659 = ((x10_long)1ll);
    x10_long i__642max__660 = n;
    {
        x10_long i__661;
        for (i__661 = i__642min__659; ((i__661) <= (i__642max__660)); i__661 =
                                                                        ((i__661) + (((x10_long)1ll))))
        {
            x10_long i__662 = i__661;
            
            //#line 21 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
            this->FMGL(tb)->bag()->add(i__662);
        }
    }
    
}

//#line 25 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
x10_boolean StaticTasks__MyTaskQueue::process(x10_long n, ::x10::glb::Context< ::StaticTasks__MyTaskQueue*, x10_long>* context) {
    
    //#line 27 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    {
        x10_long i;
        for (i = ((x10_long)0ll); (((this->FMGL(tb)->size()) > (((x10_long)0ll))) &&
                                  ((i) < (n))); i = ((i) + (((x10_long)1ll))))
        {
            
            //#line 28 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
            x10_long x = this->FMGL(tb)->bag()->removeLast();
            
            //#line 29 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
            ::x10::io::Console::FMGL(OUT__get)()->x10::io::Printer::println(
              reinterpret_cast< ::x10::lang::Any*>(::x10::lang::String::__plus(::x10::lang::String::__plus(::x10::lang::String::__plus((&::StaticTasks__MyTaskQueue_Strings::sl__672), ::x10::lang::Place::_make(::x10aux::here)), (&::StaticTasks__MyTaskQueue_Strings::sl__673)), x)));
            
            //#line 30 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
            this->FMGL(results_of_current_worker) = ((this->FMGL(results_of_current_worker)) + (x));
            
            //#line 31 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
            ::x10aux::nullCheck(context)->yield();
        }
    }
    
    //#line 33 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    return ((this->FMGL(tb)->bag()->size()) > (((x10_long)0ll)));
    
}

//#line 36 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
x10_long StaticTasks__MyTaskQueue::count() {
    
    //#line 37 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    return ((x10_long)0ll);
    
}

//#line 40 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
void StaticTasks__MyTaskQueue::merge(::x10::glb::TaskBag* _tb) {
    
    //#line 41 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    ::x10::io::Console::FMGL(OUT__get)()->x10::io::Printer::println(
      reinterpret_cast< ::x10::lang::Any*>(::x10::lang::String::__plus((&::StaticTasks__MyTaskQueue_Strings::sl__674), ::x10::lang::Place::_make(::x10aux::here))));
    
    //#line 42 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    this->FMGL(tb)->merge(reinterpret_cast< ::x10::glb::TaskBag*>(::x10aux::class_cast< ::x10::glb::ArrayListTaskBag<x10_long>*>(_tb)));
}

//#line 45 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
::x10::glb::TaskBag* StaticTasks__MyTaskQueue::split() {
    
    //#line 46 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    ::x10::io::Console::FMGL(OUT__get)()->x10::io::Printer::println(
      reinterpret_cast< ::x10::lang::Any*>(::x10::lang::String::__plus((&::StaticTasks__MyTaskQueue_Strings::sl__675), ::x10::lang::Place::_make(::x10aux::here))));
    
    //#line 47 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    return reinterpret_cast< ::x10::glb::TaskBag*>(this->FMGL(tb)->split());
    
}

//#line 50 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
void StaticTasks__MyTaskQueue::printLog() {
    
    //#line 51 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    ::x10::io::Console::FMGL(OUT__get)()->x10::io::Printer::println(
      reinterpret_cast< ::x10::lang::Any*>(::x10::lang::String::__plus((&::StaticTasks__MyTaskQueue_Strings::sl__676), ::x10::lang::Place::_make(::x10aux::here))));
}

//#line 54 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
::x10::glb::GLBResult<x10_long>* StaticTasks__MyTaskQueue::getResult(
  ) {
    
    //#line 55 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    ::x10::io::Console::FMGL(OUT__get)()->x10::io::Printer::println(
      reinterpret_cast< ::x10::lang::Any*>(::x10::lang::String::__plus((&::StaticTasks__MyTaskQueue_Strings::sl__677), ::x10::lang::Place::_make(::x10aux::here))));
    
    //#line 56 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    return reinterpret_cast< ::x10::glb::GLBResult<x10_long>*>(::StaticTasks__MyTaskQueue__MyResult::_make(this,
                                                                                                           this->FMGL(results_of_current_worker)));
    
}

//#line 14 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
::StaticTasks__MyTaskQueue* StaticTasks__MyTaskQueue::StaticTasks__MyTaskQueue____this__StaticTasks__MyTaskQueue(
  ) {
    return this;
    
}
::StaticTasks* StaticTasks__MyTaskQueue::StaticTasks__MyTaskQueue____this__StaticTasks(
  ) {
    return this->FMGL(out__);
    
}
void StaticTasks__MyTaskQueue::_constructor(::StaticTasks* out__) {
    
    //#line 12 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    this->FMGL(out__) = out__;
    
    //#line 14 "/home/torii/prog/x10/x10dev/torii/primer/StaticTasks.x10"
    this->StaticTasks__MyTaskQueue::__fieldInitializers_StaticTasks_MyTaskQueue();
}
::StaticTasks__MyTaskQueue* StaticTasks__MyTaskQueue::_make(
  ::StaticTasks* out__) {
    ::StaticTasks__MyTaskQueue* this_ = new (::x10aux::alloc_z< ::StaticTasks__MyTaskQueue>()) ::StaticTasks__MyTaskQueue();
    this_->_constructor(out__);
    return this_;
}


void StaticTasks__MyTaskQueue::__fieldInitializers_StaticTasks_MyTaskQueue(
  ) {
    this->FMGL(tb) = ::x10::glb::ArrayListTaskBag<x10_long>::_make();
    this->FMGL(results_of_current_worker) = ((x10_long)0ll);
}
const ::x10aux::serialization_id_t StaticTasks__MyTaskQueue::_serialization_id = 
    ::x10aux::DeserializationDispatcher::addDeserializer(::StaticTasks__MyTaskQueue::_deserializer);

void StaticTasks__MyTaskQueue::_serialize_body(::x10aux::serialization_buffer& buf) {
    buf.write(this->FMGL(tb));
    buf.write(this->FMGL(results_of_current_worker));
    buf.write(this->FMGL(out__));
    
}

::x10::lang::Reference* ::StaticTasks__MyTaskQueue::_deserializer(::x10aux::deserialization_buffer& buf) {
    ::StaticTasks__MyTaskQueue* this_ = new (::x10aux::alloc_z< ::StaticTasks__MyTaskQueue>()) ::StaticTasks__MyTaskQueue();
    buf.record_reference(this_);
    this_->_deserialize_body(buf);
    return this_;
}

void StaticTasks__MyTaskQueue::_deserialize_body(::x10aux::deserialization_buffer& buf) {
    FMGL(tb) = buf.read< ::x10::glb::ArrayListTaskBag<x10_long>*>();
    FMGL(results_of_current_worker) = buf.read<x10_long>();
    FMGL(out__) = buf.read< ::StaticTasks*>();
}

::x10aux::RuntimeType StaticTasks__MyTaskQueue::rtt;
void StaticTasks__MyTaskQueue::_initRTT() {
    if (rtt.initStageOne(&rtt)) return;
    const ::x10aux::RuntimeType* parents[1] = { ::x10aux::getRTT< ::x10::glb::TaskQueue< ::StaticTasks__MyTaskQueue*, x10_long> >()};
    rtt.initStageTwo("StaticTasks.MyTaskQueue",::x10aux::RuntimeType::class_kind, 1, parents, 0, NULL, NULL);
}

::x10::lang::String StaticTasks__MyTaskQueue_Strings::sl__676("MyTaskQueue#printLog at ");
::x10::lang::String StaticTasks__MyTaskQueue_Strings::sl__677("MyTaskQueue#getResult at ");
::x10::lang::String StaticTasks__MyTaskQueue_Strings::sl__674("MyTaskQueue#merge at ");
::x10::lang::String StaticTasks__MyTaskQueue_Strings::sl__670("adding ");
::x10::lang::String StaticTasks__MyTaskQueue_Strings::sl__672("running at ");
::x10::lang::String StaticTasks__MyTaskQueue_Strings::sl__675("MyTaskQueue#split at ");
::x10::lang::String StaticTasks__MyTaskQueue_Strings::sl__671(" at ");
::x10::lang::String StaticTasks__MyTaskQueue_Strings::sl__673(" processing ");

/* END of StaticTasks$MyTaskQueue */
/*************************************************/
