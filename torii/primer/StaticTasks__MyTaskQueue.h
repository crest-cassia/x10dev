#ifndef __STATICTASKS__MYTASKQUEUE_H
#define __STATICTASKS__MYTASKQUEUE_H

#include <x10rt.h>


#define X10_GLB_TASKQUEUE_H_NODEPS
#include <x10/glb/TaskQueue.h>
#undef X10_GLB_TASKQUEUE_H_NODEPS
#define X10_LANG_LONG_H_NODEPS
#include <x10/lang/Long.h>
#undef X10_LANG_LONG_H_NODEPS
#define X10_LANG_LONG_H_NODEPS
#include <x10/lang/Long.h>
#undef X10_LANG_LONG_H_NODEPS
class StaticTasks;
namespace x10 { namespace glb { 
template<class TPMGL(T)> class ArrayListTaskBag;
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
class String;
} } 
namespace x10 { namespace lang { 
class Runtime;
} } 
namespace x10 { namespace lang { 
class Place;
} } 
namespace x10 { namespace util { 
template<class TPMGL(T)> class ArrayList;
} } 
namespace x10 { namespace glb { 
template<class TPMGL(Queue), class TPMGL(R)> class Context;
} } 
namespace x10 { namespace glb { 
class TaskBag;
} } 
class StaticTasks__MyTaskQueue__MyResult;
namespace x10 { namespace compiler { 
class Synthetic;
} } 

class StaticTasks__MyTaskQueue_Strings {
  public:
    static ::x10::lang::String sl__676;
    static ::x10::lang::String sl__677;
    static ::x10::lang::String sl__674;
    static ::x10::lang::String sl__670;
    static ::x10::lang::String sl__672;
    static ::x10::lang::String sl__675;
    static ::x10::lang::String sl__671;
    static ::x10::lang::String sl__673;
};

class StaticTasks__MyTaskQueue : public ::x10::lang::X10Class   {
    public:
    RTT_H_DECLS_CLASS
    
    static ::x10aux::itable_entry _itables[3];
    
    virtual ::x10aux::itable_entry* _getITables() { return _itables; }
    
    static ::x10::glb::TaskQueue< ::StaticTasks__MyTaskQueue*, x10_long>::itable< ::StaticTasks__MyTaskQueue > _itable_0;
    
    static ::x10::lang::Any::itable< ::StaticTasks__MyTaskQueue > _itable_1;
    
    ::StaticTasks* FMGL(out__);
    
    ::x10::glb::ArrayListTaskBag<x10_long>* FMGL(tb);
    
    x10_long FMGL(results_of_current_worker);
    
    virtual void init(x10_long n);
    virtual x10_boolean process(x10_long n, ::x10::glb::Context< ::StaticTasks__MyTaskQueue*, x10_long>* context);
    virtual x10_long count();
    virtual void merge(::x10::glb::TaskBag* _tb);
    virtual ::x10::glb::TaskBag* split();
    virtual void printLog();
    virtual ::x10::glb::GLBResult<x10_long>* getResult();
    virtual ::StaticTasks__MyTaskQueue* StaticTasks__MyTaskQueue____this__StaticTasks__MyTaskQueue(
      );
    virtual ::StaticTasks* StaticTasks__MyTaskQueue____this__StaticTasks(
      );
    void _constructor(::StaticTasks* out__);
    
    static ::StaticTasks__MyTaskQueue* _make(::StaticTasks* out__);
    
    virtual void __fieldInitializers_StaticTasks_MyTaskQueue();
    
    // Serialization
    public: static const ::x10aux::serialization_id_t _serialization_id;
    
    public: virtual ::x10aux::serialization_id_t _get_serialization_id() {
         return _serialization_id;
    }
    
    public: virtual void _serialize_body(::x10aux::serialization_buffer& buf);
    
    public: static ::x10::lang::Reference* _deserializer(::x10aux::deserialization_buffer& buf);
    
    public: void _deserialize_body(::x10aux::deserialization_buffer& buf);
    
};

#endif // STATICTASKS__MYTASKQUEUE_H

class StaticTasks__MyTaskQueue;

#ifndef STATICTASKS__MYTASKQUEUE_H_NODEPS
#define STATICTASKS__MYTASKQUEUE_H_NODEPS
#ifndef STATICTASKS__MYTASKQUEUE_H_GENERICS
#define STATICTASKS__MYTASKQUEUE_H_GENERICS
#endif // STATICTASKS__MYTASKQUEUE_H_GENERICS
#endif // __STATICTASKS__MYTASKQUEUE_H_NODEPS
