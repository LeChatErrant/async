# AsynCrystal

[![Build Status](https://travis-ci.org/LeChatErrant/AsynCrystal.svg?branch=master)](https://travis-ci.org/LeChatErrant/AsynCrystal)
[![star this repo](http://githubbadges.com/star.svg?user=LeChatErrant&repo=AsynCrystal&style=default)](https://github.com/LeChatErrant/AsynCrystal)
[![fork this repo](http://githubbadges.com/fork.svg?user=LeChatErrant&repo=AsynCrystal&style=default)](https://github.com/LeChatErrant/AsynCrystal/fork)
[![GitHub Issues](https://img.shields.io/github/issues/LeChatErrant/AsynCrystal.svg)](https://github.com/LeChatErrant/AsynCrystal/issues)
[![GitHub contributors](https://img.shields.io/github/contributors/LeChatErrant/AsynCrystal.svg)](https://GitHub.com/LeChatErrant/AsynCrystal/graphs/contributors/)
![Contributions welcome](https://img.shields.io/badge/contributions-welcome-green.svg)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
> A collection of tools to manage asynchronous tasks in crystal

### Note from the creator

Hello guys! ;)

This little baby is still under heavy development. You can see my roadmap below!

This will be updated with the release of a stable version



AsynCrystal is a collection of tools to handle asynchronous tasks in crystal. It is currently divided in 3 parts (more parts may come after!) :
 - FiberPool, equivalent of a thread-pool, but using crystal fibers
 - ThreadPool, a thread-pool written in crystal. As crystal doesn't natively support threads for the moment, it is based on C bindings of pthread
 - Promise, a wrapper around asynchronous return value, just like in ES6, and providing usefull functions like `await`, `resolve` or `reject`



Actually, it's one of my first project written in Crystal : feel free to contribute, or to send tips !

And don't hesitate to give a star if you like it, of course!


## Installation

1. Add the dependency to your `shard.yml`:

```yaml
dependencies:
  AsynCrystal:
    github: LeChatErrant/AsynCrystal
```

2. Run `shards install`

## Usage

```crystal
require "AsynCrystal"
```

TODO: Write usage instructions here

## Documentation

> The documentation is not ready for now, as the project is still in development and subject to changes

https://lechaterrant.github.io/AsynCrystal/

## TODO

- [ ] FiberPool
   - [ ] Trying to take any form of procs as arguments (aborted for the moment, as Crystal doesn't seem to support templating on Procs?)
   - [x] Simple generic pool with queued jobs
   - [x] Sleeping fibers, able to be awoken by the FiberPool
   - [ ] Fully asynchronous functioning
   - [ ] "Joining" fibers at FiberPool destruction. Offering a way to "kill" fibers manually
   - [ ] Return value of fibers

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

- [ ] Promise
  - [ ] Generic promise for fork, fiber, and threads
  - [ ] Launching job when created
  - [ ] State and return value
  - [ ] await blocking method implementation
  - [ ] .then and .catch
  - [ ] .resolve and .reject

## Contributing

1. Fork it (<https://github.com/LeChatErrant/AsynCrystal/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [LeChatErrant](https://github.com/LeChatErrant) - creator and maintainer
