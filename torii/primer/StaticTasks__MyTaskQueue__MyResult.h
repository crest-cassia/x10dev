#ifndef __STATICTASKS__MYTASKQUEUE__MYRESULT_H
#define __STATICTASKS__MYTASKQUEUE__MYRESULT_H

#include <x10rt.h>


#define X10_GLB_GLBRESULT_H_NODEPS
#include <x10/glb/GLBResult.h>
#undef X10_GLB_GLBRESULT_H_NODEPS
#define X10_LANG_LONG_H_NODEPS
#include <x10/lang/Long.h>
#undef X10_LANG_LONG_H_NODEPS
#define X10_LANG_LONG_H_NODEPS
#include <x10/lang/Long.h>
#undef X10_LANG_LONG_H_NODEPS
class StaticTasks__MyTaskQueue;
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
template<class TPMGL(T)> class Rail;
} } 
namespace x10 { namespace lang { 
class String;
} } 
namespace x10 { namespace lang { 
class Runtime;
} } 
namespace x10 { namespace lang { 
class Place;
} } 
namespace x10 { namespace util { 
class Team;
} } 
namespace x10 { namespace compiler { 
class Synthetic;
} } 
class StaticTasks;

class StaticTasks__MyTaskQueue__MyResult_Strings {
  public:
    static ::x10::lang::String sl__667;
    static ::x10::lang::String sl__665;
    static ::x10::lang::String sl__668;
    static ::x10::lang::String sl__666;
};

class StaticTasks__MyTaskQueue__MyResult : public ::x10::glb::GLBResult<x10_long>
  {
    public:
    RTT_H_DECLS_CLASS
    
    ::StaticTasks__MyTaskQueue* FMGL(out__);
    
    x10_long FMGL(result);
    
    void _constructor(::StaticTasks__MyTaskQueue* out__, x10_long local_result);
    
    static ::StaticTasks__MyTaskQueue__MyResult* _make(::StaticTasks__MyTaskQueue* out__,
                                                       x10_long local_result);
    
    virtual ::x10::lang::Rail< x10_long >* getResult();
    virtual x10_int getReduceOperator();
    virtual void display(::x10::lang::Rail< x10_long >* r);
    virtual ::StaticTasks__MyTaskQueue__MyResult* StaticTasks__MyTaskQueue__MyResult____this__StaticTasks__MyTaskQueue__MyResult(
      );
    virtual ::StaticTasks__MyTaskQueue* StaticTasks__MyTaskQueue__MyResult____this__StaticTasks__MyTaskQueue(
      );
    virtual ::StaticTasks* StaticTasks__MyTaskQueue__MyResult____this__StaticTasks(
      );
    virtual void __fieldInitializers_StaticTasks_MyTaskQueue_MyResult(
      );
    
    // Serialization
    public: static const ::x10aux::serialization_id_t _serialization_id;
    
    public: virtual ::x10aux::serialization_id_t _get_serialization_id() {
         return _serialization_id;
    }
    
    public: virtual void _serialize_body(::x10aux::serialization_buffer& buf);
    
    public: static ::x10::lang::Reference* _deserializer(::x10aux::deserialization_buffer& buf);
    
    public: void _deserialize_body(::x10aux::deserialization_buffer& buf);
    
};

#endif // STATICTASKS__MYTASKQUEUE__MYRESULT_H

class StaticTasks__MyTaskQueue__MyResult;

#ifndef STATICTASKS__MYTASKQUEUE__MYRESULT_H_NODEPS
#define STATICTASKS__MYTASKQUEUE__MYRESULT_H_NODEPS
#ifndef STATICTASKS__MYTASKQUEUE__MYRESULT_H_GENERICS
#define STATICTASKS__MYTASKQUEUE__MYRESULT_H_GENERICS
#endif // STATICTASKS__MYTASKQUEUE__MYRESULT_H_GENERICS
#endif // __STATICTASKS__MYTASKQUEUE__MYRESULT_H_NODEPS
