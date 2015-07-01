#ifndef __STRING02_H
#define __STRING02_H

#include <x10rt.h>


namespace x10 { namespace lang { 
template<class TPMGL(T)> class Rail;
} } 
namespace x10 { namespace lang { 
class String;
} } 
namespace x10 { namespace lang { 
class Any;
} } 
namespace x10 { namespace lang { 
class Unsafe;
} } 
namespace x10 { namespace io { 
class Printer;
} } 
namespace x10 { namespace io { 
class Console;
} } 
namespace x10 { namespace compiler { 
class Synthetic;
} } 

class String02_Strings {
  public:
    static ::x10::lang::String sl__20;
};

class String02 : public ::x10::lang::X10Class   {
    public:
    RTT_H_DECLS_CLASS
    
    static void main(::x10::lang::Rail< ::x10::lang::String* >* id__0);
    virtual ::String02* String02____this__String02();
    void _constructor();
    
    static ::String02* _make();
    
    virtual void __fieldInitializers_String02();
    
    // Serialization
    public: static const ::x10aux::serialization_id_t _serialization_id;
    
    public: virtual ::x10aux::serialization_id_t _get_serialization_id() {
         return _serialization_id;
    }
    
    public: virtual void _serialize_body(::x10aux::serialization_buffer& buf);
    
    public: static ::x10::lang::Reference* _deserializer(::x10aux::deserialization_buffer& buf);
    
    public: void _deserialize_body(::x10aux::deserialization_buffer& buf);
    
};

#endif // STRING02_H

class String02;

#ifndef STRING02_H_NODEPS
#define STRING02_H_NODEPS
#ifndef STRING02_H_GENERICS
#define STRING02_H_GENERICS
#endif // STRING02_H_GENERICS
#endif // __STRING02_H_NODEPS
