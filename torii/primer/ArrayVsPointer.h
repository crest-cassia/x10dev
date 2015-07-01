#ifndef __ARRAYVSPOINTER_H
#define __ARRAYVSPOINTER_H

#include <x10rt.h>


namespace x10 { namespace lang { 
template<class TPMGL(T)> class Rail;
} } 
namespace x10 { namespace lang { 
class String;
} } 
namespace x10 { namespace util { 
template<class TPMGL(T)> class ArrayList;
} } 
class ArrayVsPointer__X;
namespace x10 { namespace util { 
template<class TPMGL(T)> class ListIterator;
} } 
namespace x10 { namespace lang { 
class System;
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

class ArrayVsPointer_Strings {
  public:
    static ::x10::lang::String sl__302;
    static ::x10::lang::String sl__301;
};

class ArrayVsPointer : public ::x10::lang::X10Class   {
    public:
    RTT_H_DECLS_CLASS
    
    static void main(::x10::lang::Rail< ::x10::lang::String* >* id__0);
    virtual ::ArrayVsPointer* ArrayVsPointer____this__ArrayVsPointer();
    void _constructor();
    
    static ::ArrayVsPointer* _make();
    
    virtual void __fieldInitializers_ArrayVsPointer();
    
    // Serialization
    public: static const ::x10aux::serialization_id_t _serialization_id;
    
    public: virtual ::x10aux::serialization_id_t _get_serialization_id() {
         return _serialization_id;
    }
    
    public: virtual void _serialize_body(::x10aux::serialization_buffer& buf);
    
    public: static ::x10::lang::Reference* _deserializer(::x10aux::deserialization_buffer& buf);
    
    public: void _deserialize_body(::x10aux::deserialization_buffer& buf);
    
};

#endif // ARRAYVSPOINTER_H

class ArrayVsPointer;

#ifndef ARRAYVSPOINTER_H_NODEPS
#define ARRAYVSPOINTER_H_NODEPS
#ifndef ARRAYVSPOINTER_H_GENERICS
#define ARRAYVSPOINTER_H_GENERICS
#endif // ARRAYVSPOINTER_H_GENERICS
#endif // __ARRAYVSPOINTER_H_NODEPS
