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




Feel free to contribute, or to send tips !

And don't hesitate to give a star if you like it, of course!


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

### Promise

Promises are not available yet! But.. currently in development! ;) Coming soon

Promise is a wrapper around an asynchronous task. This task can be handle with a crystal Fiber, a Thread, or a Process, respectively with FiberPromise, ThreadPromise, and ProcessPromise.

It is build on the Promise model of Javascript (ES6), and allow multiple action with it

#### Creating a Promise

#### Waiting a Promise

#### Return value

#### Resolve / Reject

#### Callbacks (.then / .catch)

#### Error handling

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

- [ ] Promise
  - [ ] Generic promise for process, fiber, and threads
  - [ ] Launching job when created
  - [ ] State and return value
  - [ ] await blocking method implementation
  - [ ] .then and .catch
  - [ ] .resolve and .reject

## Contributing

1. Fork it (<https://github.com/LeChatErrant/async/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [LeChatErrant](https://github.com/LeChatErrant) - creator and maintainer
