module Async
  abstract class GenericReturnValue
    abstract def initialize(value)
    abstract def get
    abstract def type
  end
end
