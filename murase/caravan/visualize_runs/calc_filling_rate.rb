require 'pp'
require 'json'
require File.expand_path('run', File.dirname(__FILE__))

runs_json_file = ARGV[0]
runs = JSON.parse( File.open(runs_json_file).read )

num_places = runs.map {|run| run["placeId"] }.max + 1
min_start_at = runs.map {|run| run["startAt"] }.min
max_finish_at = runs.map {|run| run["finishAt"] }.max
total_duration = max_finish_at - min_start_at

durations = {}
num_places.times do |i|
  runs_on_place = runs.select {|run| run["placeId"] == i }
  duration = runs_on_place.map {|run| run["finishAt"] - run["startAt"] }.inject(:+)
  durations[i] = duration
end

pp durations

result = {}
max_p = durations.max_by {|pid, duration| duration }
result["max_filling_rate"] = max_p[1].to_f / total_duration
result["max_filling_at"] = max_p[0]
min_p = durations.min_by {|pid, duration| duration }
result["min_filling_rate"] = min_p[1].to_f / total_duration
result["min_filling_at"] = min_p[0]
average_duration = durations.values.inject(:+).to_f / durations.size
result["avg_filling_rate"] = average_duration / total_duration
pp result
