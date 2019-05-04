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



Async is a collection of tools to handle asynchronous tasks in crystal. It is currently composed of :
 - FiberPool, equivalent of a thread-pool, but using crystal fibers
 - ThreadPool, a thread-pool written in crystal. As crystal doesn't natively support threads for the moment, it is based on C bindings of pthread
 - Promise, a wrapper around asynchronous return value, just like in ES6, and providing usefull functions like `await`, `resolve` or `reject`
 - more parts coming after, using process, and more!



Actually, it's one of my first project written in Crystal : feel free to contribute, or to send tips !

And don't hesitate to give a star if you like it, of course!


## Installation

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  async:
    github: LeChatErrant/async
```

2. Run `shards install`

## Usage

```crystal
require "async"

include Async
```

TODO: Write usage instructions here

## Documentation

> The documentation is not ready for now, as the project is still in development and subject to changes

https://lechaterrant.github.io/AsynCrystal/

## TODO

- [ ] FiberPool
   - [x] Trying to take any form of procs as arguments (templated Job class)
   - [x] Simple generic pool with queued jobs
   - [x] Sleeping fibers, able to be awoken by the FiberPool
   - [x] Fully asynchronous functioning
   - [x] "Joining" fibers at FiberPool destruction. Offering a way to "kill" fibers manually
   - [ ] Return value of fibers
   - [ ] wait and wait_for methods (respectively, blocking call waiting for ALL jobs to finish, and a blocking call waiting for the job given as parameter to finish)

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
  - [ ] Generic promise for fork, fiber, and threads
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
