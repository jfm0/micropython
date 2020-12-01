// adapted from https://nachtimwald.com/2019/04/05/cross-platform-thread-wrapper/
/* see https://nachtimwald.com/files/2008/11/MIT.txt
 *  Copyright John Schember <john@nachtimwald.com>
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy of
 *  this software and associated documentation files(the "Software"), to deal in
 *  the Software without restriction, including without limitation the rights to
 *  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 *  of the Software, and to permit persons to whom the Software is furnished to do
 *  so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
*/
#ifndef __CPTHREAD_H__
#define __CPTHREAD_H__

#include <stdbool.h>
#define WIN32_LEAN_AND_MEAN
#include <windows.h>

typedef CRITICAL_SECTION pthread_mutex_t;
typedef void *pthread_mutexattr_t;
typedef DWORD pthread_t;
typedef DWORD pthread_key_t;
typedef struct {
    size_t stack_size;
} pthread_attr_t;

/*
 * Mutex types.
 */
enum
{
  /* Compatibility with LinuxThreads */
  PTHREAD_MUTEX_FAST_NP,
  PTHREAD_MUTEX_RECURSIVE_NP,
  PTHREAD_MUTEX_ERRORCHECK_NP,
  PTHREAD_MUTEX_TIMED_NP = PTHREAD_MUTEX_FAST_NP,
  PTHREAD_MUTEX_ADAPTIVE_NP = PTHREAD_MUTEX_FAST_NP,
  /* For compatibility with POSIX */
  PTHREAD_MUTEX_NORMAL = PTHREAD_MUTEX_FAST_NP,
  PTHREAD_MUTEX_RECURSIVE = PTHREAD_MUTEX_RECURSIVE_NP,
  PTHREAD_MUTEX_ERRORCHECK = PTHREAD_MUTEX_ERRORCHECK_NP,
  PTHREAD_MUTEX_DEFAULT = PTHREAD_MUTEX_NORMAL
};

int pthread_create(pthread_t *thread, pthread_attr_t *attr, void *(*start_routine)(void *), void *arg);
int pthread_cancel(pthread_t thread); //< Not implemented correctly

int pthread_equal(pthread_t t1, pthread_t t2);
pthread_t pthread_self(void);

int pthread_mutex_init(pthread_mutex_t *mutex, pthread_mutexattr_t *attr);
int pthread_mutex_destroy(pthread_mutex_t *mutex);
int pthread_mutex_lock(pthread_mutex_t *mutex);
int pthread_mutex_trylock(pthread_mutex_t * mutex);
int pthread_mutex_unlock(pthread_mutex_t *mutex);
int pthread_mutexattr_init(pthread_mutexattr_t * attr);
int pthread_mutexattr_settype(pthread_mutexattr_t * attr, int kind);

// Not actually used enums
enum {
    // whatever
    PTHREAD_CANCEL_ASYNCHRONOUS   = 0,

    // whatever
    PTHREAD_CREATE_DETACHED       = 1,
};
#define PTHREAD_STACK_MIN   0

int pthread_setcanceltype(int type, int *oldtype); //< Unimplemented
int pthread_key_create(pthread_key_t * key, void(*destructor)(void *));
int pthread_key_delete(pthread_key_t key);
int pthread_setspecific(pthread_key_t key, const void *value);
void *pthread_getspecific(pthread_key_t key);
int pthread_attr_init(pthread_attr_t * attr);
int pthread_attr_setdetachstate(pthread_attr_t * attr, int detachstate);
int pthread_attr_setstacksize(pthread_attr_t * attr, size_t stacksize);

#endif /* __CPTHREAD_H__ */
