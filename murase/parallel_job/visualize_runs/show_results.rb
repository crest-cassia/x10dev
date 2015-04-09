require 'pp'
require 'json'
load File.expand_path('run.rb', File.dirname(__FILE__))

class ShowResults < Processing::App
  def setup
    size 600, 600
    json_file = File.join( File.dirname(__FILE__), 'runs.json' )
    runs = JSON.parse( File.open(json_file).read )

    min_start_at = runs.map {|run| run["startAt"] }.min
    max_finish_at = runs.map {|run| run["finishAt"] }.max
    num_places = runs.map {|run| run["placeId"] }.uniq.size
    Run.set_scale( num_places, min_start_at, max_finish_at )

    min_beta, max_beta = runs.map {|run| run["beta"] }.minmax
    min_h, max_h = runs.map {|run| run["h"] }.minmax
    @range = { beta: [min_beta, max_beta], h: [min_h, max_h] }

    @runs = runs.map {|run| Run.new( run ) }
    @time_increment = ->() {
      time = ($app.frame_count.to_f / 100) * ( max_finish_at - min_start_at ) + min_start_at
      return time
    }

    @result_range = runs.map {|run| run["result"] }.minmax
    $app.frame_rate(5)
  end

  def draw
    background(0)
    t = @time_increment.call()
    @runs.each {|run| run.draw_scatter_plot( @range, t, @result_range ) }
  end
end

ShowResults.new(x: 20, y: 20)

