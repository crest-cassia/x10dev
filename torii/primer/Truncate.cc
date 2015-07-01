/*************************************************/
/* START of Truncate */
#include <Truncate.h>

#include <x10/lang/Rail.h>
#include <x10/lang/String.h>
#include <x10/lang/Double.h>
#include <x10/lang/Boolean.h>
#include <x10/lang/Math.h>
#include <x10/io/Printer.h>
#include <x10/io/Console.h>
#include <x10/lang/Any.h>
#include <x10/compiler/Synthetic.h>
#include <x10/lang/String.h>

//#line 4 "/home/torii/prog/x10/x10dev/torii/primer/Truncate.x10"
void Truncate::main(::x10::lang::Rail< ::x10::lang::String* >* id__0) {
    
    //#line 6 "/home/torii/prog/x10/x10dev/torii/primer/Truncate.x10"
    x10_double w = 0.5;
    
    //#line 7 "/home/torii/prog/x10/x10dev/torii/primer/Truncate.x10"
    {
        x10_double d;
        for (d = (-(5.0)); ((d) < (5.1)); d = ((d) + (0.1))) {
            
            //#line 8 "/home/torii/prog/x10/x10dev/torii/primer/Truncate.x10"
            x10_double x = ((::x10::lang::MathNatives::floor(((d) / (w)))) * (w));
            
            //#line 9 "/home/torii/prog/x10/x10dev/torii/primer/Truncate.x10"
            ::x10::io::Console::FMGL(OUT__get)()->x10::io::Printer::println(
              reinterpret_cast< ::x10::lang::Any*>(::x10::lang::String::__plus(::x10::lang::String::__plus(d, (&::Truncate_Strings::sl__107)), x)));
        }
    }
    
}

//#line 2 "/home/torii/prog/x10/x10dev/torii/primer/Truncate.x10"
::Truncate* Truncate::Truncate____this__Truncate() {
    return this;
    
}
void Truncate::_constructor() {
    this->Truncate::__fieldInitializers_Truncate();
}
::Truncate* Truncate::_make() {
    ::Truncate* this_ = new (::x10aux::alloc_z< ::Truncate>()) ::Truncate();
    this_->_constructor();
    return this_;
}


void Truncate::__fieldInitializers_Truncate() {
 
}
const ::x10aux::serialization_id_t Truncate::_serialization_id = 
    ::x10aux::DeserializationDispatcher::addDeserializer(::Truncate::_deserializer);

void Truncate::_serialize_body(::x10aux::serialization_buffer& buf) {
    
}

::x10::lang::Reference* ::Truncate::_deserializer(::x10aux::deserialization_buffer& buf) {
    ::Truncate* this_ = new (::x10aux::alloc_z< ::Truncate>()) ::Truncate();
    buf.record_reference(this_);
    this_->_deserialize_body(buf);
    return this_;
}

void Truncate::_deserialize_body(::x10aux::deserialization_buffer& buf) {
    
}

::x10aux::RuntimeType Truncate::rtt;
void Truncate::_initRTT() {
    if (rtt.initStageOne(&rtt)) return;
    const ::x10aux::RuntimeType** parents = NULL; 
    rtt.initStageTwo("Truncate",::x10aux::RuntimeType::class_kind, 0, parents, 0, NULL, NULL);
}

::x10::lang::String Truncate_Strings::sl__107("  ");

/* END of Truncate */
/*************************************************/
