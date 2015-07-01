#ifndef __ARRAYVSPOINTER__X_H
#define __ARRAYVSPOINTER__X_H

#include <x10rt.h>


#define X10_LANG_LONG_H_NODEPS
#include <x10/lang/Long.h>
#undef X10_LANG_LONG_H_NODEPS
#define X10_LANG_LONG_H_NODEPS
#include <x10/lang/Long.h>
#undef X10_LANG_LONG_H_NODEPS
namespace x10 { namespace compiler { 
class Synthetic;
} } 

class ArrayVsPointer__X : public ::x10::lang::X10Class   {
    public:
    RTT_H_DECLS_CLASS
    
    x10_long FMGL(i);
    
    void _constructor(x10_long i);
    
    static ::ArrayVsPointer__X* _make(x10_long i);
    
    virtual x10_long get();
    virtual ::ArrayVsPointer__X* ArrayVsPointer__X____this__ArrayVsPointer__X(
      );
    virtual void __fieldInitializers_ArrayVsPointer_X();
    
    // Serialization
    public: static const ::x10aux::serialization_id_t _serialization_id;
    
    public: virtual ::x10aux::serialization_id_t _get_serialization_id() {
         return _serialization_id;
    }
    
    public: virtual void _serialize_body(::x10aux::serialization_buffer& buf);
    
    public: static ::x10::lang::Reference* _deserializer(::x10aux::deserialization_buffer& buf);
    
    public: void _deserialize_body(::x10aux::deserialization_buffer& buf);
    
};

#endif // ARRAYVSPOINTER__X_H

class ArrayVsPointer__X;

#ifndef ARRAYVSPOINTER__X_H_NODEPS
#define ARRAYVSPOINTER__X_H_NODEPS
#ifndef ARRAYVSPOINTER__X_H_GENERICS
#define ARRAYVSPOINTER__X_H_GENERICS
#endif // ARRAYVSPOINTER__X_H_GENERICS
#endif // __ARRAYVSPOINTER__X_H_NODEPS
