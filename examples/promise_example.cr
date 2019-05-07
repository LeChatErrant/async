require "../src/async.cr"

include Async

promise = FiberPromise.new(->(i : Int32){puts i}, 12)

puts "I'm before await"
await FiberPromise.new(->do
  puts "time for a nap!"
  sleep 2.seconds
  puts "zzz..."
  sleep 2.seconds
  puts "I'm awake! :)"
end)
puts "I'm after await"