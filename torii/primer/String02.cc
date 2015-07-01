/*************************************************/
/* START of String02 */
#include <String02.h>

#include <x10/lang/Rail.h>
#include <x10/lang/String.h>
#include <x10/lang/Long.h>
#include <x10/lang/Any.h>
#include <x10/lang/Unsafe.h>
#include <x10/io/Printer.h>
#include <x10/io/Console.h>
#include <x10/compiler/Synthetic.h>
#include <x10/lang/String.h>

//#line 4 "/home/torii/prog/x10/x10dev/torii/primer/String02.x10"
void String02::main(::x10::lang::Rail< ::x10::lang::String* >* id__0) {
    
    //#line 6 "/home/torii/prog/x10/x10dev/torii/primer/String02.x10"
    x10_long h = ((x10_long)37ll);
    
    //#line 7 "/home/torii/prog/x10/x10dev/torii/primer/String02.x10"
    x10_long m = ((x10_long)21ll);
    
    //#line 8 "/home/torii/prog/x10/x10dev/torii/primer/String02.x10"
    x10_long s = ((x10_long)12ll);
    
    //#line 10 "/home/torii/prog/x10/x10dev/torii/primer/String02.x10"
    ::x10::lang::String* time = ::x10::lang::String::format((&::String02_Strings::sl__20),(__extension__ ({
        ::x10::lang::Rail< ::x10::lang::Any* >* t__13 = ::x10::lang::Rail< ::x10::lang::Any* >::_makeUnsafe(((x10_long)3ll), false);
        t__13->x10::lang::Rail< ::x10::lang::Any* >::__set(((x10_long)0ll),
                                                           ::x10aux::class_cast_unchecked< ::x10::lang::Any*>(h));
        t__13->x10::lang::Rail< ::x10::lang::Any* >::__set(((x10_long)1ll),
                                                           ::x10aux::class_cast_unchecked< ::x10::lang::Any*>(m));
        t__13->x10::lang::Rail< ::x10::lang::Any* >::__set(((x10_long)2ll),
                                                           ::x10aux::class_cast_unchecked< ::x10::lang::Any*>(s));
        t__13;
    }))
    );
    
    //#line 11 "/home/torii/prog/x10/x10dev/torii/primer/String02.x10"
    ::x10::io::Console::FMGL(OUT__get)()->x10::io::Printer::println(reinterpret_cast< ::x10::lang::Any*>(time));
}

//#line 2 "/home/torii/prog/x10/x10dev/torii/primer/String02.x10"
::String02* String02::String02____this__String02() {
    return this;
    
}
void String02::_constructor() {
    this->String02::__fieldInitializers_String02();
}
::String02* String02::_make() {
    ::String02* this_ = new (::x10aux::alloc_z< ::String02>()) ::String02();
    this_->_constructor();
    return this_;
}


void String02::__fieldInitializers_String02() {
 
}
const ::x10aux::serialization_id_t String02::_serialization_id = 
    ::x10aux::DeserializationDispatcher::addDeserializer(::String02::_deserializer);

void String02::_serialize_body(::x10aux::serialization_buffer& buf) {
    
}

::x10::lang::Reference* ::String02::_deserializer(::x10aux::deserialization_buffer& buf) {
    ::String02* this_ = new (::x10aux::alloc_z< ::String02>()) ::String02();
    buf.record_reference(this_);
    this_->_deserialize_body(buf);
    return this_;
}

void String02::_deserialize_body(::x10aux::deserialization_buffer& buf) {
    
}

::x10aux::RuntimeType String02::rtt;
void String02::_initRTT() {
    if (rtt.initStageOne(&rtt)) return;
    const ::x10aux::RuntimeType** parents = NULL; 
    rtt.initStageTwo("String02",::x10aux::RuntimeType::class_kind, 0, parents, 0, NULL, NULL);
}

::x10::lang::String String02_Strings::sl__20("%02d:%02d:%02d");

/* END of String02 */
/*************************************************/
