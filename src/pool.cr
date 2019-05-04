module Async
  abstract class Pool
    abstract def worker

    abstract def initialize
    abstract def finalize

    abstract def push

    abstract def wait
    abstract def wait_for

    abstract def stop
    abstract def terminate
  end
end
