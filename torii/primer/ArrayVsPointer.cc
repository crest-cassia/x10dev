/*************************************************/
/* START of ArrayVsPointer */
#include <ArrayVsPointer.h>

#include <x10/lang/Rail.h>
#include <x10/lang/String.h>
#include <x10/lang/Long.h>
#include <x10/util/ArrayList.h>
#include <ArrayVsPointer__X.h>
#include <x10/lang/Boolean.h>
#include <x10/util/ListIterator.h>
#include <x10/lang/System.h>
#include <x10/io/Printer.h>
#include <x10/io/Console.h>
#include <x10/lang/Any.h>
#include <x10/compiler/Synthetic.h>
#include <x10/lang/String.h>

//#line 18 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
void ArrayVsPointer::main(::x10::lang::Rail< ::x10::lang::String* >* id__0) {
    
    //#line 20 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
    x10_long N = ((x10_long)100000ll);
    
    //#line 22 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
    ::x10::util::ArrayList< ::ArrayVsPointer__X*>* a = ::x10::util::ArrayList< ::ArrayVsPointer__X*>::_make();
    
    //#line 23 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
    x10_long i__268min__297 = ((x10_long)0ll);
    x10_long i__268max__298 = ((N) - (((x10_long)1ll)));
    {
        x10_long i__299;
        for (i__299 = i__268min__297; ((i__299) <= (i__268max__298)); i__299 =
                                                                        ((i__299) + (((x10_long)1ll))))
        {
            x10_long i__300 = i__299;
            
            //#line 24 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
            a->add(::ArrayVsPointer__X::_make(i__300));
        }
    }
    
    //#line 27 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
    x10_long sum = ((x10_long)0ll);
    
    //#line 28 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
    {
        ::x10::util::ListIterator< ::ArrayVsPointer__X*>* x__288;
        for (x__288 = reinterpret_cast< ::x10::util::ListIterator< ::ArrayVsPointer__X*>*>(a->iterator());
             ::x10::util::ListIterator< ::ArrayVsPointer__X*>::hasNext(::x10aux::nullCheck(x__288));
             ) {
            ::ArrayVsPointer__X* x = ::x10::util::ListIterator< ::ArrayVsPointer__X*>::next(::x10aux::nullCheck(x__288));
            
            //#line 29 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
            sum = ((sum) + (::x10aux::nullCheck(x)->FMGL(i)));
        }
    }
    
    //#line 32 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
    x10_long begin0 = ::x10::lang::System::nanoTime();
    
    //#line 33 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
    {
        ::x10::util::ListIterator< ::ArrayVsPointer__X*>* x__290;
        for (x__290 = reinterpret_cast< ::x10::util::ListIterator< ::ArrayVsPointer__X*>*>(a->iterator());
             ::x10::util::ListIterator< ::ArrayVsPointer__X*>::hasNext(::x10aux::nullCheck(x__290));
             ) {
            ::ArrayVsPointer__X* x = ::x10::util::ListIterator< ::ArrayVsPointer__X*>::next(::x10aux::nullCheck(x__290));
            
            //#line 34 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
            ::x10aux::nullCheck(x)->get();
        }
    }
    
    //#line 36 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
    x10_long end0 = ::x10::lang::System::nanoTime();
    
    //#line 38 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
    x10_long begin1 = ::x10::lang::System::nanoTime();
    
    //#line 39 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
    {
        ::x10::util::ListIterator< ::ArrayVsPointer__X*>* x__292;
        for (x__292 = reinterpret_cast< ::x10::util::ListIterator< ::ArrayVsPointer__X*>*>(a->iterator());
             ::x10::util::ListIterator< ::ArrayVsPointer__X*>::hasNext(::x10aux::nullCheck(x__292));
             ) {
            ::ArrayVsPointer__X* x = ::x10::util::ListIterator< ::ArrayVsPointer__X*>::next(::x10aux::nullCheck(x__292));
            
            //#line 40 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
            ::x10aux::nullCheck(a->__apply(::x10aux::nullCheck(x)->FMGL(i)))->get();
        }
    }
    
    //#line 42 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
    x10_long end1 = ::x10::lang::System::nanoTime();
    
    //#line 44 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
    x10_long begin2 = ::x10::lang::System::nanoTime();
    
    //#line 45 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
    {
        ::x10::util::ListIterator< ::ArrayVsPointer__X*>* x__294;
        for (x__294 = reinterpret_cast< ::x10::util::ListIterator< ::ArrayVsPointer__X*>*>(a->iterator());
             ::x10::util::ListIterator< ::ArrayVsPointer__X*>::hasNext(::x10aux::nullCheck(x__294));
             ) {
            ::ArrayVsPointer__X* x = ::x10::util::ListIterator< ::ArrayVsPointer__X*>::next(::x10aux::nullCheck(x__294));
            
            //#line 46 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
            ::x10aux::nullCheck(x)->get();
        }
    }
    
    //#line 48 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
    x10_long end2 = ::x10::lang::System::nanoTime();
    
    //#line 50 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
    x10_long begin3 = ::x10::lang::System::nanoTime();
    
    //#line 51 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
    {
        ::x10::util::ListIterator< ::ArrayVsPointer__X*>* x__296;
        for (x__296 = reinterpret_cast< ::x10::util::ListIterator< ::ArrayVsPointer__X*>*>(a->iterator());
             ::x10::util::ListIterator< ::ArrayVsPointer__X*>::hasNext(::x10aux::nullCheck(x__296));
             ) {
            ::ArrayVsPointer__X* x = ::x10::util::ListIterator< ::ArrayVsPointer__X*>::next(::x10aux::nullCheck(x__296));
            
            //#line 52 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
            ::x10aux::nullCheck(a->__apply(::x10aux::nullCheck(x)->FMGL(i)))->get();
        }
    }
    
    //#line 54 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
    x10_long end3 = ::x10::lang::System::nanoTime();
    
    //#line 56 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
    ::x10::io::Console::FMGL(OUT__get)()->x10::io::Printer::println(
      reinterpret_cast< ::x10::lang::Any*>(::x10::lang::String::__plus((&::ArrayVsPointer_Strings::sl__301), ((end0) - (begin0)))));
    
    //#line 57 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
    ::x10::io::Console::FMGL(OUT__get)()->x10::io::Printer::println(
      reinterpret_cast< ::x10::lang::Any*>(::x10::lang::String::__plus((&::ArrayVsPointer_Strings::sl__302), ((end1) - (begin1)))));
    
    //#line 58 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
    ::x10::io::Console::FMGL(OUT__get)()->x10::io::Printer::println(
      reinterpret_cast< ::x10::lang::Any*>(::x10::lang::String::__plus((&::ArrayVsPointer_Strings::sl__301), ((end2) - (begin2)))));
    
    //#line 59 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
    ::x10::io::Console::FMGL(OUT__get)()->x10::io::Printer::println(
      reinterpret_cast< ::x10::lang::Any*>(::x10::lang::String::__plus((&::ArrayVsPointer_Strings::sl__302), ((end3) - (begin3)))));
}

//#line 3 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
::ArrayVsPointer* ArrayVsPointer::ArrayVsPointer____this__ArrayVsPointer(
  ) {
    return this;
    
}
void ArrayVsPointer::_constructor() {
    this->ArrayVsPointer::__fieldInitializers_ArrayVsPointer();
}
::ArrayVsPointer* ArrayVsPointer::_make() {
    ::ArrayVsPointer* this_ = new (::x10aux::alloc_z< ::ArrayVsPointer>()) ::ArrayVsPointer();
    this_->_constructor();
    return this_;
}


void ArrayVsPointer::__fieldInitializers_ArrayVsPointer() {
 
}
const ::x10aux::serialization_id_t ArrayVsPointer::_serialization_id = 
    ::x10aux::DeserializationDispatcher::addDeserializer(::ArrayVsPointer::_deserializer);

void ArrayVsPointer::_serialize_body(::x10aux::serialization_buffer& buf) {
    
}

::x10::lang::Reference* ::ArrayVsPointer::_deserializer(::x10aux::deserialization_buffer& buf) {
    ::ArrayVsPointer* this_ = new (::x10aux::alloc_z< ::ArrayVsPointer>()) ::ArrayVsPointer();
    buf.record_reference(this_);
    this_->_deserialize_body(buf);
    return this_;
}

void ArrayVsPointer::_deserialize_body(::x10aux::deserialization_buffer& buf) {
    
}

::x10aux::RuntimeType ArrayVsPointer::rtt;
void ArrayVsPointer::_initRTT() {
    if (rtt.initStageOne(&rtt)) return;
    const ::x10aux::RuntimeType** parents = NULL; 
    rtt.initStageTwo("ArrayVsPointer",::x10aux::RuntimeType::class_kind, 0, parents, 0, NULL, NULL);
}

::x10::lang::String ArrayVsPointer_Strings::sl__302("Array  : ");
::x10::lang::String ArrayVsPointer_Strings::sl__301("Pointer: ");

/* END of ArrayVsPointer */
/*************************************************/
/*************************************************/
/* START of ArrayVsPointer$X */
#include <ArrayVsPointer__X.h>

#include <x10/lang/Long.h>
#include <x10/compiler/Synthetic.h>

//#line 7 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"

//#line 9 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
void ArrayVsPointer__X::_constructor(x10_long i) {
    
    //#line 5 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
    this->ArrayVsPointer__X::__fieldInitializers_ArrayVsPointer_X();
    
    //#line 10 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
    this->FMGL(i) = i;
}
::ArrayVsPointer__X* ArrayVsPointer__X::_make(x10_long i) {
    ::ArrayVsPointer__X* this_ = new (::x10aux::alloc_z< ::ArrayVsPointer__X>()) ::ArrayVsPointer__X();
    this_->_constructor(i);
    return this_;
}



//#line 13 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
x10_long ArrayVsPointer__X::get() {
    
    //#line 14 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
    return ((x10_long)0ll);
    
}

//#line 5 "/home/torii/prog/x10/x10dev/torii/primer/ArrayVsPointer.x10"
::ArrayVsPointer__X* ArrayVsPointer__X::ArrayVsPointer__X____this__ArrayVsPointer__X(
  ) {
    return this;
    
}
void ArrayVsPointer__X::__fieldInitializers_ArrayVsPointer_X() {
    this->FMGL(i) = ((x10_long)0ll);
}
const ::x10aux::serialization_id_t ArrayVsPointer__X::_serialization_id = 
    ::x10aux::DeserializationDispatcher::addDeserializer(::ArrayVsPointer__X::_deserializer);

void ArrayVsPointer__X::_serialize_body(::x10aux::serialization_buffer& buf) {
    buf.write(this->FMGL(i));
    
}

::x10::lang::Reference* ::ArrayVsPointer__X::_deserializer(::x10aux::deserialization_buffer& buf) {
    ::ArrayVsPointer__X* this_ = new (::x10aux::alloc_z< ::ArrayVsPointer__X>()) ::ArrayVsPointer__X();
    buf.record_reference(this_);
    this_->_deserialize_body(buf);
    return this_;
}

void ArrayVsPointer__X::_deserialize_body(::x10aux::deserialization_buffer& buf) {
    FMGL(i) = buf.read<x10_long>();
}

::x10aux::RuntimeType ArrayVsPointer__X::rtt;
void ArrayVsPointer__X::_initRTT() {
    if (rtt.initStageOne(&rtt)) return;
    const ::x10aux::RuntimeType** parents = NULL; 
    rtt.initStageTwo("ArrayVsPointer.X",::x10aux::RuntimeType::class_kind, 0, parents, 0, NULL, NULL);
}

/* END of ArrayVsPointer$X */
/*************************************************/
