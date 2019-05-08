# async

[![Build Status](https://travis-ci.org/LeChatErrant/async.svg?branch=master)](https://travis-ci.org/LeChatErrant/async)
[![star this repo](http://githubbadges.com/star.svg?user=LeChatErrant&repo=async&style=default)](https://github.com/LeChatErrant/async)
[![fork this repo](http://githubbadges.com/fork.svg?user=LeChatErrant&repo=async&style=default)](https://github.com/LeChatErrant/async/fork)
[![GitHub Issues](https://img.shields.io/github/issues/LeChatErrant/async.svg)](https://github.com/LeChatErrant/async/issues)
[![GitHub contributors](https://img.shields.io/github/contributors/LeChatErrant/async.svg)](https://GitHub.com/LeChatErrant/async/graphs/contributors/)
![Contributions welcome](https://img.shields.io/badge/contributions-welcome-green.svg)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
> A collection of tools to manage asynchronous tasks in crystal

### Note from the creator

Hello guys! ;)

This little baby is still under heavy development. You can see my roadmap below!

This will be updated with the release of a stable version

## Async

The purpose of Async is to offer a collection of usefull tools to handle asynchronous tasks in crystal.

It comes with :

 - Promise, a wrapper allowing the user to do complex actions in only one line, such as
   - Waiting for a task to be completed
   - Running task in background and get their result later
   - Assigning callbacks on success / error for an asynchronous task
   - and many many more! ;)

 - Pool, a tool based on a classic thread pool architecture. It allows the user to
   - launch multiple asynchronous workers, always ready to execute tasks
   - add tasks to the pool. Workers will take it for you and execute it asynchronously in the bakckground!
   - control the execution of MANY jobs simultaneous with different methods
   - not to relaunch, for example, a Thread, each time you want to launch an action in the background : here, the workers are launched only ONE time, and are picking differents tasks!

Every class comes with three different implementation, each time using a different type of worker :
 - Fibers : native crystal green thread, those you can invoke using `spawn`
 - Threads : as crystal doesn't natively support threads for the moment, it is based on C bindings of pthread
 - Process : an entire process, with a lighter memory


___

Feel free to contribute, or to send tips !

And don't hesitate to give a star if you like it, of course!

____

## Installation

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  async:
    github: LeChatErrant/async
```

2. Run `shards install`

## Documentation

> The documentation is not ready for now, as the project is still in development and subject to changes

https://lechaterrant.github.io/async/

## Usage

```crystal
require "async"

include Async
```

___

### Promise

Promises are still currently in development! ;)

Promise is a wrapper around an asynchronous task. This task can be handle with a crystal Fiber, a Thread, or a Process, respectively with FiberPromise, ThreadPromise, and ProcessPromise.

It is build on the Promise model of Javascript (ES6), and allow multiple action with it

Each Promise has the same api (see Documentation), see below for an example using FiberPromise

#### Creating a Promise

Keep in mind that here, we're working with FiberPromise, so the asynchronous task is launched in a Fiber. With a ThreadPool, it would have been a Thread, and with a ProcessPool, an entire Process

Using bracket notation

```crystal
promise = FiberPromise.new(->{ puts "Hello" })
# Notice that creating a Promise immediatly launches the wrapped Proc
```

Using do/end notation

```crystal
promise = FiberPromise.new(->(arg : String) do
  puts arg
end, "Hello")
# Notice that arguments are given after the Proc
# You code won't compile if you forget an argument
```

From an existing function

```crystal
def say(arg : String)
  puts arg
end

proc_say = ->say(String)
promise = FiberPromise.new(proc_say, "Hello)
# Or simply
promise = FiberPromise.new(->say(String), "Hello")
```

#### Waiting a Promise

`await` block the execution until the given Proc is finished

```crystal
await FiberPromise.new(-> do
  puts "time for a nap!"
  sleep 2.seconds
  puts "zzz..."
  sleep 2.seconds
  puts "I'm awake! :)"
end)
puts "I'm after await"
```

It's usefull to wait for a specific task before your program continues

Waiting for an already resolved Promise won't have any effect

```crystal
promise = FiberPromise.new(->{ puts "hello" })
await promise
```

#### Return value

Try to display a promise : you'll get its state!

```crystal
puts promise  # #<Async::FiberPromise:object_id> PENDING
puts promise.state  # PENDING
# .get will return it's state too until resolved
puts promise.get  # PENDING
```

A promise is said PENDING when currently executed, RESOLVED when finished, and REJECTED if an error was thrown

When the promise is resolved, you can access its value

```crystal
promised_value = await promise
puts promised_value # returned value
puts promise.get  # returned value
puts promise.state  # RESOLVED
puts promise  # #<Async::FiberPromise:object_id> RESOLVED
```

Of course, you can use the keyword `return` inside a Promise, and return different types of values, and multiple values at the same time

```crystal
conditionnal_proc = ->(toggle : Bool) do
  if toggle
    return "I received true! :)"
  end
  return false, "I received false... :("
end
puts await FiberPromise.new(conditionnal_proc, true)  # I received true! :)
puts await FiberPromise.new(conditionnal_proc, false) # {false, "I received false... :("}
```

#### Error handling

Errors can be thrown inside a Promise, and are caught for you : the return value will be the Exception raised

```crystal
promise = FiberPromise.new(->{
  raise "Oh, no!"
})

value = await promise
puts value  # Oh, no!
puts value.class  # Exception
```

#### Resolve / Reject

When you're inside a promise, prefere using `resolve` and `reject`, instead of `return` and `raise`.

Basically, it does the same thing, but indicates you're handling a Promise, and not something else

```crystal
conditionnal_proc = ->(toggle : Bool) do
  if toggle
    resolve "I received true! :)"
  end
  resolve false, "I received false... :("
end
puts await FiberPromise.new(conditionnal_proc, true)  # I received true! :)
puts await FiberPromise.new(conditionnal_proc, false) # {false, "I received false... :("
```

`reject` works the same way `raise` works, so you can reject either a String or an Exception

```crystal
promise = FiberPromise.new(->{
  reject "Oh, no!"
})

value = await promise
puts value  # Oh, no!
puts value.class  # Exception

promise = FiberPromise.new(->{
  reject Exception.new("Oh, no!")
})

value = await promise
puts value  # Oh, no!
puts value.class  # Exception
```

#### Callbacks (.then / .catch)

> Promise callbacks are still under development! Don't use it for the moment, as it's still not stable.

Callbacks are pieces of code which will be executed AFTER your Promise, asynchronously. You can add a callback like this :

```crystal
FiberPromise.new(->{
  # do something
}).then(->{
  # will be executed once the Promise is RESOLVED
})
```

.then is for adding callbacks on RESOlVE

You can use .catch for adding callbacks on REJECT

```crystal
FiberPromise.new(->{
  reject "oh no!"
}).catch((e : Exception)->{
  puts "{e.message}"
})
```

You can have callbacks on RESOLVE and REJECT simultaneously, to execute code depending on the promise state.

```crystal
promise = FiberPromise.new(->{
  # Do something
})

promise.then(->{ "RESOLVED" })
promise.catch(->{ "REJECTED" })
```

Notice that adding a callback on a state will override the older one on the same state

#### .finally

With .finally, you can add callback which will be called in any case

```crystal
FiberPromise.new(->{
  # Do something
}).finally({
  # Will be called either if the Promise was RESOLVED or REJECTED
})
```

#### Chaining callbacks

Adding a callback return a new Promise object

It means you can chain callbacks, like this :

```crystal
FiberPromise.new(->{
  # Do something
}).then(->{
  "RESOLVED"
}).catch(->{
  "REJECTED"
}).finally(->{
  "ANY CASE"
})
```

If, for example, an error is thrown, every THEN blocks will be skipped until a CATCH or FINALLY block is found

```crystal
FiberPromise.new(->{
  reject "Oh no!"
}).then(->{
  "I won't be called if an error is thrown..."
}).catch(->{
  "Gotcha!"
})
```

With this, you can totally control your asynchronous flow :) enjoy!

___

### Pool

Async offer you different kinds of workers pool :
 - FiberPool
 - ThreadPool (In developpement)
 - ProcessPool (Not implemented yet)

Each pool has the same api (see Documentation)

Here is an example using a FiberPool, but this works with any kind of pool!

#### Creating a pool

Keep in mind that here, a worker is a crystal Fiber. With a ThreadPool, it would have been a Thread, and with a ProcessPool, an entire Process

```crystal
pool = FiberPool.new(3) # Create and launch a pool with 3 workers
```

#### Adding jobs

You can add jobs by multiple way :
 - From a block, using do/end notation

```crystal
pool.push(->do
  puts "hello"
end)
```

 - From a block, using bracket notation

```crystal
pool.push(->(i : Int32) { puts i }, 12)
# Notice that arguments are givent after the Proc!
# If you forget one argument, your code won't compile
```

 - From an existing function

```crystal
def my_function(x : Int32, y : Int32)
  sleep 1.seconds
  puts x
  sleep 3.seconds
  puts y
  "hello"
end

my_function_proc = ->my_function(Int32, Int32)
pool.push(my_function_proc, 1, 2)
# Or simply
pool.push(->my_function(Int32, Int32), 1, 2)
```

 - You can add a job with the `wait_for` method too. It'll block the execution until a worker has picked and executed this job

```crystal
fiber_pool.wait_for(->{
  puts "Let's sleep a bit"
  sleep 3.seconds
  puts "I'm done with sleeping!"
})
# Execution will continue once "I'm done with sleeping!" have been displayed
```

#### Pool control

Async give you some way to control your workers pool :

 - The `wait` method, blocking the execution until every jobs have been executed

```crystal
pool.wait
# Execution will continue once every jobs will be finished
```

 - The `finish` method, blocking the execution until every jobs have been executed, and then kill all workers. Notice that you can't use the pool after this, as it's a way to destroy it

```crystal
pool.finish
# Execution blocked until every jobs will be finished and workers killed
```

 - The `stop` method. Once stop have been called, the pool will finish all currently executed jobs, when kill every workers. Notice that all the pending jobs will be lost! It's usefull when you want to stop the pool without executing all queues tasks. Stop is not a blocking call, but you can't use the pool after this, as it's a way to destroy it

```crystal
pool.stop
# Execution not blocked, currently started jobs finishing in background, pending jobs lost, and fibers killed in background
```

 - The `terminate` method, killing all workers instataneously, without finishing any job!

```crystal
# Unfortunatly, not implemented for the moment... Sorry <3
```

 - The `finalize` is used to destroy the pool : it will finish in the background every jobs, and kill workers. It's the equivalent of the `finish` method, but without stoping the execution. As it's a way to destroy the pool, you can't use it after this

```crystal
pool.finalize
```

## TODO

- [ ] FiberPool
   - [x] Trying to take any form of procs as arguments (templated Job class)
   - [x] Simple generic pool with queued jobs
   - [x] Sleeping fibers, able to be awoken by the FiberPool
   - [x] Fully asynchronous functioning
   - [x] "Joining" fibers at FiberPool destruction. Offering a way to "kill" fibers manually
   - [ ] Return value of fibers
   - [x] wait and wait_for methods (respectively, blocking call waiting for ALL jobs to finish, and a blocking call waiting for the job given as parameter to finish)
   - [x] documented api

- [ ] ThreadPool
   - [ ] Abstract class above FiberPool and ThreadPool, to make users able to substitute fibers by threads
   - [ ] Thread class, an encapsulation of pthread_t
   - [ ] Mutex class, an encapsulation of pthread_mutex_t
   - [ ] ConditionVariable class, an encapsulation of pthread_cond_t
   - [ ] SafeQueue, wrapping Dequeu and Mutex
   - [ ] ThreadChannel, wrapping SafeQueue and ConditionVariable
   - [ ] ThreadWorker, the worker launched in each threads at the ThreadPool creation! It is sleeping when no jobs are in the ThreadChannel, and awoken when some job is pushed in the ThreadPool
   - [ ] Threads joining
   - [ ] Threads return value

- [ ] ProcessPool
   - [ ] Roadmap to be defined!

- [ ] FiberPromise
  - [x] Launching generic job in fiber at creation
  - [x] State and return value
  - [x] await blocking method implementation
  - [x] error throwing
  - [ ] .then and .catch
  - [ ] chaining .then and .catch
  - [ ] .finally
  - [x] resolve and reject keywords
  - [ ] documented code

- [ ] ThreadPromise
   - [ ] Roadmap to be defined!

- [ ] ProcessPromise
   - [ ] Roadmap to be defined!


## Contributing

1. Fork it (<https://github.com/LeChatErrant/async/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [LeChatErrant](https://github.com/LeChatErrant) - creator and maintainer
