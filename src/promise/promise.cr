module Async
  def await(promise : Promise)
    promise.wait
  end

  def await(type : T.class, promise : Promise) forall T
    puts T
    promise.wait.as(T)
  end

  macro resolve(*values)
    return {{*values}}
  end

  def reject(message : String) : NoReturn
    raise Exception.new(message)
  end

  def reject(exception : Exception) : NoReturn
    raise exception
  end

  enum PromiseState
    PENDING
    RESOLVED
    REJECTED
  end

  private abstract class Promise
    abstract def initialize
    abstract def wait
    abstract def get
    abstract def then(callable)
    abstract def catch(callable)
    abstract def finally(callable)
    abstract def to_s(io : IO) : Nil
    abstract def state
  end
end
