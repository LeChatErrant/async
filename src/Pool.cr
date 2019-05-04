module AsynCrystal
  abstract class Pool
    abstract def worker

    abstract def initialize
    abstract def finalize

    abstract def push
    abstract def stop
    abstract def terminate
  end
end
