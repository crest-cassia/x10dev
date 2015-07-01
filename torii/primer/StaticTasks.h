#ifndef __STATICTASKS_H
#define __STATICTASKS_H

#include <x10rt.h>


namespace x10 { namespace lang { 
template<class TPMGL(U)> class Fun_0_0;
} } 
class StaticTasks__MyTaskQueue;
namespace x10 { namespace glb { 
template<class TPMGL(Queue), class TPMGL(R)> class GLB;
} } 
namespace x10 { namespace glb { 
class GLBParameters;
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
class VoidFun_0_0;
} } 
namespace x10 { namespace lang { 
template<class TPMGL(T)> class Rail;
} } 
namespace x10 { namespace lang { 
class String;
} } 
namespace x10 { namespace compiler { 
class Synthetic;
} } 

class StaticTasks_Strings {
  public:
    static ::x10::lang::String sl__663;
};

class StaticTasks : public ::x10::lang::X10Class   {
    public:
    RTT_H_DECLS_CLASS
    
    virtual void run(x10_long n);
    static void main(::x10::lang::Rail< ::x10::lang::String* >* args);
    virtual ::StaticTasks* StaticTasks____this__StaticTasks();
    void _constructor();
    
    static ::StaticTasks* _make();
    
    virtual void __fieldInitializers_StaticTasks();
    
    // Serialization
    public: static const ::x10aux::serialization_id_t _serialization_id;
    
    public: virtual ::x10aux::serialization_id_t _get_serialization_id() {
         return _serialization_id;
    }
    
    public: virtual void _serialize_body(::x10aux::serialization_buffer& buf);
    
    public: static ::x10::lang::Reference* _deserializer(::x10aux::deserialization_buffer& buf);
    
    public: void _deserialize_body(::x10aux::deserialization_buffer& buf);
    
};

#endif // STATICTASKS_H

class StaticTasks;

#ifndef STATICTASKS_H_NODEPS
#define STATICTASKS_H_NODEPS
#ifndef STATICTASKS_H_GENERICS
#define STATICTASKS_H_GENERICS
#endif // STATICTASKS_H_GENERICS
#endif // __STATICTASKS_H_NODEPS
