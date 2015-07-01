/*************************************************/
/* START of HashMap02 */
#include <HashMap02.h>

#include <x10/lang/Rail.h>
#include <x10/lang/String.h>
#include <x10/util/HashMap.h>
#include <x10/lang/Long.h>
#include <x10/io/Printer.h>
#include <x10/io/Console.h>
#include <x10/lang/Any.h>
#include <x10/lang/Iterator.h>
#include <x10/util/Map__Entry.h>
#include <x10/util/Map.h>
#include <x10/lang/Iterable.h>
#include <x10/util/Set.h>
#include <x10/lang/Boolean.h>
#include <x10/compiler/Synthetic.h>
#include <x10/lang/String.h>

//#line 7 "/home/torii/prog/x10/x10dev/torii/primer/HashMap02.x10"
void HashMap02::main(::x10::lang::Rail< ::x10::lang::String* >* id__0) {
    
    //#line 8 "/home/torii/prog/x10/x10dev/torii/primer/HashMap02.x10"
    ::x10::util::HashMap< ::x10::lang::String*, x10_long>* h = ::x10::util::HashMap< ::x10::lang::String*, x10_long>::_make();
    
    //#line 9 "/home/torii/prog/x10/x10dev/torii/primer/HashMap02.x10"
    h->put((&::HashMap02_Strings::sl__248), ((x10_long)1ll));
    
    //#line 10 "/home/torii/prog/x10/x10dev/torii/primer/HashMap02.x10"
    h->put((&::HashMap02_Strings::sl__249), ((x10_long)2ll));
    
    //#line 11 "/home/torii/prog/x10/x10dev/torii/primer/HashMap02.x10"
    h->__set((&::HashMap02_Strings::sl__250), ((x10_long)3ll));
    
    //#line 12 "/home/torii/prog/x10/x10dev/torii/primer/HashMap02.x10"
    ::x10::io::Console::FMGL(OUT__get)()->x10::io::Printer::println(::x10aux::class_cast_unchecked< ::x10::lang::Any*>(h->__apply(
                                                                                                                         (&::HashMap02_Strings::sl__250))));
    
    //#line 14 "/home/torii/prog/x10/x10dev/torii/primer/HashMap02.x10"
    ::x10::io::Console::FMGL(OUT__get)()->x10::io::Printer::println(
      ::x10aux::class_cast_unchecked< ::x10::lang::Any*>(h->get((&::HashMap02_Strings::sl__249))));
    
    //#line 16 "/home/torii/prog/x10/x10dev/torii/primer/HashMap02.x10"
    x10_long a = h->get((&::HashMap02_Strings::sl__248));
    
    //#line 17 "/home/torii/prog/x10/x10dev/torii/primer/HashMap02.x10"
    ::x10::io::Console::FMGL(OUT__get)()->x10::io::Printer::println(
      ::x10aux::class_cast_unchecked< ::x10::lang::Any*>(a));
    
    //#line 19 "/home/torii/prog/x10/x10dev/torii/primer/HashMap02.x10"
    {
        ::x10::lang::Iterator< ::x10::util::Map__Entry< ::x10::lang::String*, x10_long>*>* entry__247;
        for (entry__247 = ::x10::util::Set< ::x10::util::Map__Entry< ::x10::lang::String*, x10_long>*>::iterator(::x10aux::nullCheck(h->entries()));
             ::x10::lang::Iterator< ::x10::util::Map__Entry< ::x10::lang::String*, x10_long>*>::hasNext(::x10aux::nullCheck(entry__247));
             ) {
            ::x10::util::Map__Entry< ::x10::lang::String*, x10_long>* entry =
              ::x10::lang::Iterator< ::x10::util::Map__Entry< ::x10::lang::String*, x10_long>*>::next(::x10aux::nullCheck(entry__247));
            
            //#line 21 "/home/torii/prog/x10/x10dev/torii/primer/HashMap02.x10"
            ::x10::io::Console::FMGL(OUT__get)()->x10::io::Printer::println(
              reinterpret_cast< ::x10::lang::Any*>(::x10::lang::String::__plus(::x10::lang::String::__plus(::x10::util::Map__Entry< ::x10::lang::String*, x10_long>::getKey(::x10aux::nullCheck(entry)), (&::HashMap02_Strings::sl__251)), ::x10::util::Map__Entry< ::x10::lang::String*, x10_long>::getValue(::x10aux::nullCheck(entry)))));
        }
    }
    
    //#line 24 "/home/torii/prog/x10/x10dev/torii/primer/HashMap02.x10"
    x10_long b = h->remove((&::HashMap02_Strings::sl__249));
    
    //#line 26 "/home/torii/prog/x10/x10dev/torii/primer/HashMap02.x10"
    x10_long c = h->getOrElse((&::HashMap02_Strings::sl__252),
                              ((x10_long)9ll));
    
}

//#line 5 "/home/torii/prog/x10/x10dev/torii/primer/HashMap02.x10"
::HashMap02* HashMap02::HashMap02____this__HashMap02() {
    return this;
    
}
void HashMap02::_constructor() {
    this->HashMap02::__fieldInitializers_HashMap02();
}
::HashMap02* HashMap02::_make() {
    ::HashMap02* this_ = new (::x10aux::alloc_z< ::HashMap02>()) ::HashMap02();
    this_->_constructor();
    return this_;
}


void HashMap02::__fieldInitializers_HashMap02() {
 
}
const ::x10aux::serialization_id_t HashMap02::_serialization_id = 
    ::x10aux::DeserializationDispatcher::addDeserializer(::HashMap02::_deserializer);

void HashMap02::_serialize_body(::x10aux::serialization_buffer& buf) {
    
}

::x10::lang::Reference* ::HashMap02::_deserializer(::x10aux::deserialization_buffer& buf) {
    ::HashMap02* this_ = new (::x10aux::alloc_z< ::HashMap02>()) ::HashMap02();
    buf.record_reference(this_);
    this_->_deserialize_body(buf);
    return this_;
}

void HashMap02::_deserialize_body(::x10aux::deserialization_buffer& buf) {
    
}

::x10aux::RuntimeType HashMap02::rtt;
void HashMap02::_initRTT() {
    if (rtt.initStageOne(&rtt)) return;
    const ::x10aux::RuntimeType** parents = NULL; 
    rtt.initStageTwo("HashMap02",::x10aux::RuntimeType::class_kind, 0, parents, 0, NULL, NULL);
}

::x10::lang::String HashMap02_Strings::sl__248("A");
::x10::lang::String HashMap02_Strings::sl__249("B");
::x10::lang::String HashMap02_Strings::sl__252("C");
::x10::lang::String HashMap02_Strings::sl__250("D");
::x10::lang::String HashMap02_Strings::sl__251(":");

/* END of HashMap02 */
/*************************************************/
