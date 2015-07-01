#ifndef __TRUNCATE_H
#define __TRUNCATE_H

#include <x10rt.h>


namespace x10 { namespace lang { 
template<class TPMGL(T)> class Rail;
} } 
namespace x10 { namespace lang { 
class String;
} } 
namespace x10 { namespace lang { 
class Math;
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

class Truncate_Strings {
  public:
    static ::x10::lang::String sl__107;
};

class Truncate : public ::x10::lang::X10Class   {
    public:
    RTT_H_DECLS_CLASS
    
    static void main(::x10::lang::Rail< ::x10::lang::String* >* id__0);
    virtual ::Truncate* Truncate____this__Truncate();
    void _constructor();
    
    static ::Truncate* _make();
    
    virtual void __fieldInitializers_Truncate();
    
    // Serialization
    public: static const ::x10aux::serialization_id_t _serialization_id;
    
    public: virtual ::x10aux::serialization_id_t _get_serialization_id() {
         return _serialization_id;
    }
    
    public: virtual void _serialize_body(::x10aux::serialization_buffer& buf);
    
    public: static ::x10::lang::Reference* _deserializer(::x10aux::deserialization_buffer& buf);
    
    public: void _deserialize_body(::x10aux::deserialization_buffer& buf);
    
};

#endif // TRUNCATE_H

class Truncate;

#ifndef TRUNCATE_H_NODEPS
#define TRUNCATE_H_NODEPS
#ifndef TRUNCATE_H_GENERICS
#define TRUNCATE_H_GENERICS
#endif // TRUNCATE_H_GENERICS
#endif // __TRUNCATE_H_NODEPS
