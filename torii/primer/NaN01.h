#ifndef __NAN01_H
#define __NAN01_H

#include <x10rt.h>


namespace x10 { namespace lang { 
template<class TPMGL(T)> class Rail;
} } 
namespace x10 { namespace lang { 
class String;
} } 
namespace x10 { namespace io { 
class Printer;
} } 
namespace x10 { namespace io { 
class Console;
} } 
namespace x10 { namespace lang { 
class Any;
} } 
namespace x10 { namespace compiler { 
class Synthetic;
} } 

class NaN01 : public ::x10::lang::X10Class   {
    public:
    RTT_H_DECLS_CLASS
    
    static void main(::x10::lang::Rail< ::x10::lang::String* >* id__0);
    virtual ::NaN01* NaN01____this__NaN01();
    void _constructor();
    
    static ::NaN01* _make();
    
    virtual void __fieldInitializers_NaN01();
    
    // Serialization
    public: static const ::x10aux::serialization_id_t _serialization_id;
    
    public: virtual ::x10aux::serialization_id_t _get_serialization_id() {
         return _serialization_id;
    }
    
    public: virtual void _serialize_body(::x10aux::serialization_buffer& buf);
    
    public: static ::x10::lang::Reference* _deserializer(::x10aux::deserialization_buffer& buf);
    
    public: void _deserialize_body(::x10aux::deserialization_buffer& buf);
    
};

#endif // NAN01_H

class NaN01;

#ifndef NAN01_H_NODEPS
#define NAN01_H_NODEPS
#ifndef NAN01_H_GENERICS
#define NAN01_H_GENERICS
#endif // NAN01_H_GENERICS
#endif // __NAN01_H_NODEPS
