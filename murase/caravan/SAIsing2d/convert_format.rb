require 'pp'
require 'json'

unless ARGV.size == 2
  $stderr.puts "Usage: ruby #{__FILE__} ps_ids.txt runs.json"
  raise "invalid argument"
end

runs = JSON.load( File.read( ARGV[1] ) )

File.open(ARGV[0]).each do |line|
  psid = line.to_i
  run = runs.find {|run| run["parentPSId"] == psid }
  $stdout.puts run["result"][0]
end

