value1 = nil
value2 = {true, "hello"}

def test(value)
  case value
  when Tuple
    puts "Tuple!"
  else
    puts "Not tuple!"
  end
end
test(value1)
test(value2)

abstract class GenericProc
  abstract def initialize(callable)
  abstract def call
end

class MyProc(T) < GenericProc

  def initialize(@callable : T)
    # {% unless @callable.is_a? Proc %}
    #   {{ raise "You can only build promise with Proc" }}
    # {% end %}
  end

  def shift_tuple(head, *tail)
    frag = {head, tail}
    tail
  end

  def bind(callable, args)
    return callable if callable.arity == 0
    callable = callable.partial(args.first?)
    bind(callable, shift_tuple(*args))
  end

  def call(*args)
    callable = bind(@callable.dup, args)
  end
end

# test = {12, "bonjour", true}
# puts test
# head, tail = shift_tuple(*test)
# puts head, tail

proc = ->(i : Int32, str : String) { puts "#{str} : #{i}" }
puts proc.class
generic_proc = MyProc(typeof(proc)).new(proc)
generic_proc.call(12, "hello")