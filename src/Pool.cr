module AsynCrystal

  abstract class Pool
    abstract def initialize
    abstract def push
    abstract def terminate
    abstract def finalize
  end

end