require "./generic_function.cr"

module Async
  class Function(*T)
    def initialize(*@args : *T)
      puts T
    end

    def wrap(callable)
      {% begin %}
        {% for i in 0...T.size %}
          puts {{T[i]}}
        {% end %}
      {% end %}
    end
  end
end
