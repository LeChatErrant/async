require "./src/AsynCrystal.cr"

def print_numbers_and_say_hello(x, y)
  puts x
  puts y
  return "hello"
end

fiber_pool = AsynCrystal::FiberPool.new(1)
fiber_pool.verbose_level = Logger::DEBUG


sleep