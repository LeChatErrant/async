proc = ->(i : Int32) { puts i }
proc2 = ->do puts "hello" end

x = proc.call 1
y = proc2.call

puts x, y
