module Async
  def await(promise : Promise)
    promise.wait
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
  end
end
