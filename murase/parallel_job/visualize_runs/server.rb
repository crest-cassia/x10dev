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

def calc_fillting_rate(runs)
  min_start_at = runs.map {|run| run["startAt"] }.min
  max_finish_at = runs.map {|run| run["finishAt"] }.max
  num_places = runs.uniq {|run| run["placeId"] }.size
  duration = runs.inject(0) {|sum,run| sum + (run["finishAt"] - run["startAt"]) }
  filling_rate = duration.to_f / ((max_finish_at - min_start_at) * num_places)
  filling_rate
end

$stderr.puts "filling_rate: #{calc_fillting_rate(runs)}"

# example: /filter?x0=1&x1=2
#  => list of parameter sets whose point is [1,2,...]
get '/filter' do
  content_type :json
  selected = parameter_sets
  params.each_pair do |key,val|
    n = key[1..-1].to_i
	  v = val.to_i
	  selected = selected.select do |ps|
      ps["point"][n] == v
    end
  end

  # TODO: tentative implementation
  selected.each {|ps| ps["result"] = ps["point"].inject(:+) }
  selected.to_json
end

# /domains  =>
# interface Domains {
#   numParams: number;
#   paramDomains: Domain[];  // size: numParams
#   numOutputs: number;
#   outputDomains: Domain[]; // size: numOutputs
# }
# interface Domain {
#   min: number;
#   max: number;
# }
get '/domains' do
  content_type :json

  num_params = parameter_sets.first["point"].size
  param_domains = Array.new(num_params) do |i|
    d = parameter_sets.map {|ps| ps["point"][i] }.minmax
    {min: d[0], max: d[1]}
  end

  num_outputs = 1
  output_domains = Array.new(num_outputs) do |i|
    # d = parameter_sets.map {|ps| ps["results"][i] }.minmax
    d = parameter_sets.map {|ps| ps["point"].inject(:+) }.minmax  # TODO: temporary implementation
    {min: d[0], max: d[1]}
  end

  { numParams: num_params,
    paramDomains: param_domains,
    numOutputs: num_outputs,
    outputDomains: output_domains
  }.to_json
end

get '/runs' do
  content_type :json
  runs.to_json
end
