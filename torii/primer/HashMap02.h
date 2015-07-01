#ifndef __HASHMAP02_H
#define __HASHMAP02_H

#include <x10rt.h>


namespace x10 { namespace lang { 
template<class TPMGL(T)> class Rail;
} } 
namespace x10 { namespace lang { 
class String;
} } 
namespace x10 { namespace util { 
template<class TPMGL(K), class TPMGL(V)> class HashMap;
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
namespace x10 { namespace lang { 
template<class TPMGL(T)> class Iterator;
} } 
namespace x10 { namespace util { 
template<class TPMGL(Key), class TPMGL(Val)> class Map__Entry;
} } 
namespace x10 { namespace util { 
template<class TPMGL(K), class TPMGL(V)> class Map;
} } 
namespace x10 { namespace lang { 
template<class TPMGL(T)> class Iterable;
} } 
namespace x10 { namespace util { 
template<class TPMGL(T)> class Set;
} } 
namespace x10 { namespace compiler { 
class Synthetic;
} } 

class HashMap02_Strings {
  public:
    static ::x10::lang::String sl__248;
    static ::x10::lang::String sl__249;
    static ::x10::lang::String sl__252;
    static ::x10::lang::String sl__250;
    static ::x10::lang::String sl__251;
};

class HashMap02 : public ::x10::lang::X10Class   {
    public:
    RTT_H_DECLS_CLASS
    
    static void main(::x10::lang::Rail< ::x10::lang::String* >* id__0);
    virtual ::HashMap02* HashMap02____this__HashMap02();
    void _constructor();
    
    static ::HashMap02* _make();
    
    virtual void __fieldInitializers_HashMap02();
    
    // Serialization
    public: static const ::x10aux::serialization_id_t _serialization_id;
    
    public: virtual ::x10aux::serialization_id_t _get_serialization_id() {
         return _serialization_id;
    }
    
    public: virtual void _serialize_body(::x10aux::serialization_buffer& buf);
    
    public: static ::x10::lang::Reference* _deserializer(::x10aux::deserialization_buffer& buf);
    
    public: void _deserialize_body(::x10aux::deserialization_buffer& buf);
    
};

#endif // HASHMAP02_H

class HashMap02;

#ifndef HASHMAP02_H_NODEPS
#define HASHMAP02_H_NODEPS
#ifndef HASHMAP02_H_GENERICS
#define HASHMAP02_H_GENERICS
#endif // HASHMAP02_H_GENERICS
#endif // __HASHMAP02_H_NODEPS
