module Async
  def await(promise : Promise)
    promise.wait
  end

  macro resolve(*values)
  end

  def reject(error)
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
    abstract def then
    abstract def catch
    abstract def resolve
    abstract def reject
    abstract def to_s(io : IO) : Nil
    abstract def state
  end
end
