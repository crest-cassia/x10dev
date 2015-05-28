class ParameterSet

  def initialize( ps_hash, runs )
    @id = ps_hash["id"]
    @params = ps_hash["params"]
    @runs = runs.find_all {|r| r.parent_ps_id == @id }
  end

  def start_time
    @runs.map {|run| run.start_at }.min
  end

  def finish_time
    @runs.map {|run| run.finish_at }.max
  end

  def avg_result
    @runs.map {|run| run.result["orderParameter"] }.inject(:+)/@runs.size
  end

  def draw_scatter_plot( range = { beta: [0.1,0.5], h:[-1.0, -0.6] }, t = 0, result_range = [-1.0, 1.0] )
    x,y = range.map do |key, (min,max)|
      (@params[key.to_s] - min).to_f / (max - min)
    end
    x *= $app.width
    y *= $app.height

    if t > start_time and t < finish_time
      $app.fill(255,255,0)
      $app.ellipse( x, y, 40, 40 )
    elsif t >= finish_time
      r = (avg_result - result_range[0]).to_f / ( result_range[1] - result_range[0] )
      from = $app.color( 0, 0, 255 )
      to = $app.color( 255, 0, 0 )
      c = $app.lerp_color( from, to, r )
      $app.fill( c )
      $app.ellipse( x, y, 20, 20 )
    else
      $app.fill(64)
    end
  end
end

