/*************************************************/
/* START of NaN01 */
#include <NaN01.h>

#include <x10/lang/Rail.h>
#include <x10/lang/String.h>
#include <x10/io/Printer.h>
#include <x10/io/Console.h>
#include <x10/lang/Any.h>
#include <x10/lang/Double.h>
#include <x10/lang/Long.h>
#include <x10/compiler/Synthetic.h>

//#line 4 "/home/torii/prog/x10/x10dev/torii/primer/NaN01.x10"
void NaN01::main(::x10::lang::Rail< ::x10::lang::String* >* id__0) {
    
    //#line 5 "/home/torii/prog/x10/x10dev/torii/primer/NaN01.x10"
    ::x10::io::Console::FMGL(OUT__get)()->x10::io::Printer::println(::x10aux::class_cast_unchecked< ::x10::lang::Any*>(((::x10::lang::DoubleNatives::fromLongBits(0x7ff8000000000000LL)) - (((x10_double) (((x10_long)2ll)))))));
    
    //#line 6 "/home/torii/prog/x10/x10dev/torii/primer/NaN01.x10"
    ::x10::io::Console::FMGL(OUT__get)()->x10::io::Printer::println(::x10aux::class_cast_unchecked< ::x10::lang::Any*>(((::x10::lang::DoubleNatives::fromLongBits(0x7ff8000000000000LL)) + (((x10_double) (((x10_long)2ll)))))));
    
    //#line 7 "/home/torii/prog/x10/x10dev/torii/primer/NaN01.x10"
    ::x10::io::Console::FMGL(OUT__get)()->x10::io::Printer::println(::x10aux::class_cast_unchecked< ::x10::lang::Any*>(((::x10::lang::DoubleNatives::fromLongBits(0x7ff8000000000000LL)) * (((x10_double) (((x10_long)2ll)))))));
    
    //#line 8 "/home/torii/prog/x10/x10dev/torii/primer/NaN01.x10"
    ::x10::io::Console::FMGL(OUT__get)()->x10::io::Printer::println(::x10aux::class_cast_unchecked< ::x10::lang::Any*>(((::x10::lang::DoubleNatives::fromLongBits(0x7ff8000000000000LL)) / (((x10_double) (((x10_long)2ll)))))));
    
    //#line 10 "/home/torii/prog/x10/x10dev/torii/primer/NaN01.x10"
    ::x10::io::Console::FMGL(OUT__get)()->x10::io::Printer::println(::x10aux::class_cast_unchecked< ::x10::lang::Any*>(((::x10::lang::DoubleNatives::toLong(::x10::lang::DoubleNatives::fromLongBits(0x7ff8000000000000LL))) - (((x10_long)2ll)))));
    
    //#line 11 "/home/torii/prog/x10/x10dev/torii/primer/NaN01.x10"
    ::x10::io::Console::FMGL(OUT__get)()->x10::io::Printer::println(::x10aux::class_cast_unchecked< ::x10::lang::Any*>(((::x10::lang::DoubleNatives::toLong(::x10::lang::DoubleNatives::fromLongBits(0x7ff8000000000000LL))) + (((x10_long)2ll)))));
    
    //#line 12 "/home/torii/prog/x10/x10dev/torii/primer/NaN01.x10"
    ::x10::io::Console::FMGL(OUT__get)()->x10::io::Printer::println(::x10aux::class_cast_unchecked< ::x10::lang::Any*>(((::x10::lang::DoubleNatives::toLong(::x10::lang::DoubleNatives::fromLongBits(0x7ff8000000000000LL))) * (((x10_long)2ll)))));
    
    //#line 13 "/home/torii/prog/x10/x10dev/torii/primer/NaN01.x10"
    ::x10::io::Console::FMGL(OUT__get)()->x10::io::Printer::println(::x10aux::class_cast_unchecked< ::x10::lang::Any*>(((::x10::lang::DoubleNatives::toLong(::x10::lang::DoubleNatives::fromLongBits(0x7ff8000000000000LL))) / ::x10aux::zeroCheck(((x10_long)2ll)))));
}

//#line 2 "/home/torii/prog/x10/x10dev/torii/primer/NaN01.x10"
::NaN01* NaN01::NaN01____this__NaN01() {
    return this;
    
}
void NaN01::_constructor() {
    this->NaN01::__fieldInitializers_NaN01();
}
::NaN01* NaN01::_make() {
    ::NaN01* this_ = new (::x10aux::alloc_z< ::NaN01>()) ::NaN01();
    this_->_constructor();
    return this_;
}


void NaN01::__fieldInitializers_NaN01() {
 
}
const ::x10aux::serialization_id_t NaN01::_serialization_id = 
    ::x10aux::DeserializationDispatcher::addDeserializer(::NaN01::_deserializer);

void NaN01::_serialize_body(::x10aux::serialization_buffer& buf) {
    
}

::x10::lang::Reference* ::NaN01::_deserializer(::x10aux::deserialization_buffer& buf) {
    ::NaN01* this_ = new (::x10aux::alloc_z< ::NaN01>()) ::NaN01();
    buf.record_reference(this_);
    this_->_deserialize_body(buf);
    return this_;
}

void NaN01::_deserialize_body(::x10aux::deserialization_buffer& buf) {
    
}

::x10aux::RuntimeType NaN01::rtt;
void NaN01::_initRTT() {
    if (rtt.initStageOne(&rtt)) return;
    const ::x10aux::RuntimeType** parents = NULL; 
    rtt.initStageTwo("NaN01",::x10aux::RuntimeType::class_kind, 0, parents, 0, NULL, NULL);
}

/* END of NaN01 */
/*************************************************/
