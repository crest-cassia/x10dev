require 'pp'
require 'sinatra'
require 'json'

set :public_folder, File.dirname(__FILE__) + '/'

unless ARGV.size == 2 or ARGV.size == 1
  $stderr.puts "Usage: ruby server.rb runs.json [parameter_sets.json]"
  raise "invalid argument"
end

runs = JSON.parse( File.open(ARGV[0]).read )
parameter_sets = JSON.parse( File.open(ARGV[1]).read ) if ARGV[1]

min_start_at = runs.map {|run| run["startAt"] }.min
runs.each {|run| run["startAt"] -= min_start_at; run["finishAt"] -= min_start_at }

# example: /filter?x0=1&x1=2
#  => list of parameter sets whose point is [1,2,...]
get '/filter' do
  content_type :json
  selected = parameter_sets
  pp params
  params.each_pair do |key,val|
    n = key[1..-1].to_i
	v = val.to_i
	selected = selected.select do |ps|
      ps["point"][n] == v
    end
  end
  selected.to_json
end

# example: /domain?x=x0
#  => { x0: [ min_of_x0, max_of_x0 ], y: [ min_of_result, max_of_result ] }
get '/domain' do
  content_type :json
  n = params["x"][1..-1].to_i
  x_minmax = parameter_sets.map {|ps| ps["point"][n] }.minmax
  y_minmax = parameter_sets.map {|ps| ps["result"] }.minmax
  {x: x_minmax, y: y_minmax}.to_json
end

get '/runs' do
  content_type :json
  runs.to_json
end
