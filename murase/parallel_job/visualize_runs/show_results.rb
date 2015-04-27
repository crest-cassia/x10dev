require 'pp'
require 'json'
require 'fileutils'
load File.expand_path('run.rb', File.dirname(__FILE__))
load File.expand_path('parameter_set.rb', File.dirname(__FILE__))

class ShowResults < Processing::App
  def setup
    $stderr.puts ARGV
    unless ARGV.size == 3 or ARGV.size == 2
      $stderr.puts "usage: rp5 run show_results.rb parameter_sets.json runs.json [mov_dir]"
      raise "invalid argument"
    end

    size 600, 600
    runs_json_file = File.join( File.dirname(__FILE__), ARGV[1] )
    ps_json_file = File.join( File.dirname(__FILE__), ARGV[0] )
    runs = JSON.parse( File.open(runs_json_file).read )
    pss = JSON.parse( File.open(ps_json_file).read )


    min_start_at = runs.map {|run| run["startAt"] }.min
    max_finish_at = runs.map {|run| run["finishAt"] }.max
    num_places = runs.map {|run| run["placeId"] }.uniq.size

    min_beta, max_beta = pss.map {|ps| ps["params"]["beta"] }.minmax
    min_h, max_h = pss.map {|ps| ps["params"]["h"] }.minmax
    @range = { beta: [min_beta, max_beta], h: [min_h, max_h] }

    @runs = runs.map {|run| Run.new( run ) }
    @pss = pss.map {|ps| ParameterSet.new( ps, @runs ) }
    @time_increment = ->() {
      time = ($app.frame_count.to_f / 100) * ( max_finish_at - min_start_at ) + min_start_at
      return time
    }

    @result_range = @runs.map {|run| run.result["orderParameter"] }.minmax
    $app.frame_rate(5)

    if ARGV[2]
      @snapshot_dir = ARGV[2]
      FileUtils.mkdir_p( @snapshot_dir )
    end
  end

  def draw
    background(0)
    t = @time_increment.call()
    @pss.each {|ps| ps.draw_scatter_plot( @range, t, @result_range ) }
    if @snapshot_dir
      $app.save_frame( File.join( Dir.pwd, @snapshot_dir, "frame-####.tif") )
      exit if $app.frame_count > 100
    end
  end
end

ShowResults.new(x: 20, y: 20)

