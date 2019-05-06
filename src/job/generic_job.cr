module Async
  private abstract class GenericJob
    abstract def initialize(callable, args)
    abstract def call
  end
end
