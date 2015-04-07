require 'pp'

files = %w(build/task_list.txt build/ising2d.out build/Main$$Main.class build/json-simple-1.1.1.jar)
files.each {|f| File.exist?(f) or raise "File #{f} not found" }
puts "[OK] All files are found!"

