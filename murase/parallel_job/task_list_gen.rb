require 'pp'

betas = (2..6).map {|i| i/10.0 }
hs = (-10..10).step(2).map {|i| i/10.0 }

id = 1
betas.each do |beta|
  hs.each do |h|
    cmd = "../../build/ising2d.out 99 100 #{beta} #{h} 10000 10000 #{rand(100000)}"
    puts "#{id}: #{cmd}"
    id += 1
  end
end

