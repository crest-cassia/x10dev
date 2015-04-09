require 'pp'
require 'json'
require File.expand_path('run', File.dirname(__FILE__))

class ShowTimeline < Processing::App
  def setup
    size 600, 600
    json_file = File.join( File.dirname(__FILE__), 'runs.json' )
    runs = JSON.parse( File.open(json_file).read )

    min_start_at = runs.map {|run| run["startAt"] }.min
    max_finish_at = runs.map {|run| run["finishAt"] }.max
    num_places = runs.map {|run| run["placeId"] }.uniq.size
    Run.set_scale( num_places, min_start_at, max_finish_at )

    @runs = runs.map {|run| Run.new( run ) }
  end

  def draw
    background(0)
    @runs.each {|run| run.show }
  end
end

ShowTimeline.new(x: 100, y: 100)

