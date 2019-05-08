module Async
  private abstract class GenericFunction
    abstract def initialize(callable)
    abstract def call
  end
end
