module AsynCrystal

  abstract class Pool
    abstract def initialize
    abstract def add_job
    abstract def terminate
    abstract def finalize
  end

end