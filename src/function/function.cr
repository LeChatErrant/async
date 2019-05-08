require "./generic_function.cr"

module Async
  class Function(T) < GenericFunction
    def initialize(@callable : T)
    end

    def call(*args)
      @callable.call *args
    end
  end
end
