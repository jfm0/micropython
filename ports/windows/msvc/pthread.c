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

#include "pthread.h"

int pthread_attr_init(pthread_attr_t * attr)
{
    attr->stack_size = 0;
    return 0;
}

int pthread_attr_setdetachstate(pthread_attr_t * attr, int detachstate)
{
    return 0;
}

int pthread_attr_setstacksize(pthread_attr_t * attr, size_t stacksize)
{
    attr->stack_size = stacksize;
    return 0;
}

int pthread_create(pthread_t *thread, pthread_attr_t *attr, void *(*start_routine)(void *), void *arg)
{
    if (thread == NULL || start_routine == NULL)
        return 1;

    *thread = CreateThread(NULL, attr->stack_size, start_routine, arg, 0, NULL);
    if (*thread == NULL)
        return 1;
    return 0;
}

int pthread_equal(pthread_t t1, pthread_t t2)
{
    return (t1 == t2);
}

pthread_t pthread_self(void)
{
    return GetCurrentThread();
}


int pthread_mutex_init(pthread_mutex_t *mutex, pthread_mutexattr_t *attr)
{
    (void)attr;

    if (mutex == NULL)
        return 1;

    InitializeCriticalSection(mutex);
    return 0;
}

int pthread_mutex_destroy(pthread_mutex_t *mutex)
{
    if (mutex == NULL)
        return 1;
    DeleteCriticalSection(mutex);
    return 0;
}

int pthread_mutex_lock(pthread_mutex_t *mutex)
{
    if (mutex == NULL)
        return 1;
    EnterCriticalSection(mutex);
    return 0;
}

int pthread_mutex_trylock(pthread_mutex_t *mutex)
{
    if (mutex == NULL)
        return 1;
    if(TryEnterCriticalSection(mutex))
    {
        return 0;
    }
    return EBUSY;
}

int pthread_mutex_unlock(pthread_mutex_t *mutex)
{
    if (mutex == NULL)
        return 1;
    LeaveCriticalSection(mutex);
    return 0;
}

int pthread_mutexattr_init(pthread_mutexattr_t * attr)
{
    return 0;
}

int pthread_mutexattr_settype(pthread_mutexattr_t * attr, int kind)
{
    return 0;
}

int pthread_setcanceltype (int type, int *oldtype)
{
    (void)type; (void)oldtype;
    return 0;
}

int pthread_key_create(pthread_key_t * key, void(*destructor)(void *))
{
    DWORD dwTlsIndex = TlsAlloc();
    if (dwTlsIndex == TLS_OUT_OF_INDEXES)
    {
        return EAGAIN;
    }
    *key = dwTlsIndex;
    return 0;
}

int pthread_key_delete(pthread_key_t key)
{
    TlsFree(key);
    return 0;
}

int pthread_setspecific(pthread_key_t key, const void *value)
{
    if (! TlsSetValue(key, value))
        return GetLastError();

    return 0;
}

void *pthread_getspecific(pthread_key_t key)
{
    void *lpvData = TlsGetValue(key);
    return lpvData;
}
