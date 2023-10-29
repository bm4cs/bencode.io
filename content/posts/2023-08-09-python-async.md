---
layout: post
draft: false
title: "Async Python"
slug: "pythonasync"
date: "2023-08-09 21:12:33+11:00"
lastmod: "2023-08-09 21:12:33+11:00"
comments: false
categories:
  - python
tags:
  - python
  - dev
  - code
---

## Background

Using `asyncio` will not make your code multi-threaded. That is, it will not cause multiple Python instructions to be executed at the same time, and it will not in any way allow you to side step the so-called “global interpreter lock” (GIL).

Some processes are CPU-bound: they consist of a series of instructions which need to be executed one after another until the result has been computed. Most of their time is spent making heavy use of the processor.

Other processes, however, are IO-bound: they spend a lot of time sending and receiving data from external devices or processes, and hence often need to start an operation and then wait for it to complete before carrying on. Whilst waiting they aren’t doing very much.

`asyncio` allows you to structure your code so that when one piece of linear single-threaded code (coroutine) is waiting for something to happen, another can take over and leverage the CPU.

> It’s not about using multiple cores, it’s about using a single core more efficiently

### Event loop

With `asyncio` you no longer only have one stack per thread. Instead each thread has an _Event Loop_. The event loop has a list of objects called `Tasks`. Each `Task` maintains a single stack, and its own execution pointer as well.

At any one time the event loop can only have one `Task` executing, whilst the other tasks in the loop are all paused. The currently executing task will continue to execute exactly as if it were executing a function in a normal (synchronous) Python program, right up until it gets to a point where it would have to wait for something to happen before it can continue.

Then, instead of waiting, the code in the `Task` _yields_ control. This means that it asks the event loop to pause the `Task` it is running in, and wake it up again at a future point once the thing it needs to wait for has happened.

The event loop can then select one of its other sleeping tasks to wake up and become the executing task instead. Or if none of them are able to awaken (because they’re all waiting for things to happen) then it can wait.

This way the CPU’s time can be shared between different tasks, all of which are executing code capable of yielding like this when they would otherwise wait.

This execution pattern, where code control moves back and forth between different tasks, waking them back up at the point where they left off each time is called _coroutine calling_, and this is what `asyncio` brings to Python, as a means to better utilising CPUs that would otherwise sit idle.

**Importantly**, an event loop cannot forcibly interrupt a coroutine that is currently executing. A coroutine that is executing will continue executing until it yields control. The event loop serves to select which coroutine to schedule next, and keeps track of which coroutines are blocked and unable to execute until some IO has completed, but it only does these things when no coroutine is currently executing.

## Awaitables

An object is _awaitable_ if it can be used in an `await` expression. Many `asyncio` APIs are designed to accept awaitables, of which there are three main types: `Coroutine`, `Task` and `Future`.

## Coroutines

`async def` declares an asynchronous coroutine function in the same way that `def` is used to define a vanilla synchronous function.

- Async code can only be included inside a suitable context that allows it, which almost always is within a coroutine function defined using `async def`. One other async context will be covered later.
- Async code can leverage all and any standard Python keywords, structures, etc. While nothing is technically disallowed, some things are discouraged.
- There are several new keywords which can only be used inside an async context: `await`, `async with` and `async for`.

The `async def` keyword creates a callable object with a name, when the object is called the code block of the function is not run.

```python
async def cool_coroutine(a, b, c):
    ...

r = cool_coroutine(1, 2, 3)
```

Does not cause the `cool_coroutine` code block to be run. Instead an object of class `Coroutine` is created, and is assigned to `r`. To make the code block actually run you need to make use of one of the facilities that `asyncio` provides for running a coroutine. Most commonly this is the `await` keyword. The function `asyncio.gather` is used in an example below. Other examples can be found in the [docs](https://docs.python.org/3.10/library/asyncio-task.html#running-an-asyncio-program).

A crucial concept to drive home is that the currently executing `Task` cannot be paused by any means other than awaiting a future. That is something which can only happen inside async code. So any `await` statement might cause your current task to pause, but is not guaranteed to. Conversely any statement which is not an `await` statement (or an `async for` or `async with` under certain circumstances) cannot cause your current `Task` to be paused.

```python
import asyncio

async def get_some_values_from_io():
    # Some IO code which returns a list of values
    ...

vals = []

async def fetcher():
    while True:
        io_vals = await get_some_values_from_io()

        for val in io_vals:
            vals.append(io_vals)

async def monitor():
    while True:
        print (len(vals))

        await asyncio.sleep(1)

async def main():
    t1 = asyncio.create_task(fetcher())
    t2 = asyncio.create_task(monitor())
    await asyncio.gather(t1, t2)

    # could be simplified to just:
    # asyncio.gather(fetcher(), monitor())

asyncio.run(main())
```

Even though both `fetcher` and `monitor` access the global variable `vals` they do so in two tasks that are running in the same event loop. As a result, its not possible for the print statement in `monitor` to run unless `fetcher` is currently asleep waiting for io. This means that its not possible for the length of `vals` to be printed whilst the `for` loop is only part-way through running. So if the `get_some_values_from_io` always returns 10 values at a time, then the printed length of `vals` will always be a multiple of 10. Its simply not possible for the print statement to execute at a time when `vals` has a non-multiple of ten length.

On the other hand if there was an `await` statement inside the for loop this would no longer be guaranteed. That is, the event loop would have the opportunity to schedule the other Task.

## Futures

A `Future` object is a type of awaitable. Unlike a coroutine when a future is awaited it does not cause a block of code to be executed. Instead a future object can be thought of as representing some process that is ongoing which may or may not yet be finished.

Running `await` on a future causes the following:

- If the process the future represents has finished and returned a value then the `await` statement immediately returns that value.
- If the process the future represents has finished and raised an exception then the `await` statement immediately raises that exception.
- If the process the future represents has not yet finished then the current `Task` is paused until the process has finished. Once it is finished it behaves as described in the first two bullet points here.

IN addition to being awaitable all `Future` objects support the following synchronous interface:

- `f.done()` returns `True` if the process the future represents has finished.
- `f.exception()` raises an `asyncio.InvalidStateError` exception if the process has not yet finished. If the process has finished it returns the exception it raised, or `None` if it terminated without raising.
- `f.result()` raises an `asyncio.InvalidStateError` exception if the process has not yet finished. If the process has finished it raises the exception it raised, or returns the value it returned if it finished without raising.

⚠️ The difference between a `Coroutine` and a `Future` may seem subtle. A Coroutine’s code will not be executed until it is awaited. A future represents something that is executing anyway, and simply allows your code to wait for it to finish, check if it has finished, and fetch the result if it has.

⚠️ Objects which implement the `__await__` dunder method may do almost anything when awaited. They might behave more like Coroutines, or more like Futures. They may do something else entirely.

## Tasks

Each event loop contains one or more tasks, and every coroutine that is executing is doing so inside a task. Creating a task is a simple matter, and can be done entirely in synchronous code:

```python
async def example_coroutine_function():
    ...

t = asyncio.create_task(example_coroutine_function())
```

The method `create_task` takes a coroutine object as a parameter and returns a `Task` object, which inherits from `asyncio.Future`. The call creates the task inside the event loop for the current thread, and starts the task executing at the beginning of the coroutine’s code-block. The returned future will be marked as `done()` only when the task has finished execution. As you might expect the return value of the coroutine’s code block is the `result()` which will be stored in the future object when it is finished (and if it `raises` then the exception will be caught and stored in the future).

Creating a task to wrap a `coroutine` is a synchronous call, so it can be done anywhere, including inside synchronous or asynchronous code. If you do it in asynchronous code then the event loop is already running (since it is currently executing your asynchronous code), and when it next gets the opportunity (i.e. next time your current task pauses) it might make the new task active.

When you do it in synchronous code, however, chances are that the event loop is not yet running. Manualy manipulating event loops is discouranged by the python documentation. Unless you are developing libraries extending `asyncio` functionality, you should probably avoid trying to create a task from synchronous code.

If you do need to call a single piece of async code in an otherwise synchronous script, you can use `asyncio.run()`.

## Typings

### Awaitable

If you are using typing then there is an abstract class `Awaitable` which is generic, so that `Awaitable[R]` for some type R means _anything which is awaitable, and when used in an await statement will return something of type R_.

### Future

If you want to specify that a variable is a `Future` then you can use the `asyncio.Future` class as a type annotation. If you want to specify that the Future’s result should be of a specific type, R then you can use the following notation:

```python
f: asyncio.Future[R]
```

## Working example

```python
import asyncio

async def counter(name: str):
    for i in range(0, 100):
        print(f"{name}: {i!s}")
        await asyncio.sleep(0)

async def main():
    tasks = []
    for n in range(0, 4):
        tasks.append(asyncio.create_task(counter(f"task{n}")))

    while True:
        tasks = [t for t in tasks if not t.done()]
        if len(tasks) == 0:
            return

        await tasks[0]

asyncio.run(main())
```

<https://docs.python.org/3/library/asyncio-task.html>

<https://bbc.github.io/cloudfit-public-docs/asyncio/asyncio-part-1>
