require "./generic_return_value.cr"

module Async
  class ReturnValue(T) < GenericReturnValue
    def initialize(@value : T)
    end

    def get
      @value
    end
  end
end
