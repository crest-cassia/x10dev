require 'pp'
require 'json'
require File.expand_path('run', File.dirname(__FILE__))

class ShowTimeline < Processing::App

  def setup
    $stderr.puts ARGV
    unless ARGV.size == 1
      $stderr.puts "usage: rp5 run show_timeline.rb runs.json"
      raise "invalid argument"
    end

    size 600, 600
    runs_json_file = ARGV[0]
    runs = JSON.parse( File.open(runs_json_file).read )

    min_start_at = runs.map {|run| run["startAt"] }.min
    max_finish_at = runs.map {|run| run["finishAt"] }.max
    @time_scale = [ min_start_at, max_finish_at ]
    @num_places = runs.map {|run| run["placeId"] }.uniq.size

    @runs = runs.map {|run| Run.new( run ) }
  end

  def draw
    background(0)
    @runs.each {|run| run.draw_timeline( @num_places, @time_scale ) }
  end
end

ShowTimeline.new(x: 100, y: 100)

