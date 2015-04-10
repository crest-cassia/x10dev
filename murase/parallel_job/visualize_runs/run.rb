class Run

  def initialize( run_hash )
    @place = run_hash["placeId"]
    @start_at = run_hash["startAt"]
    @finish_at = run_hash["finishAt"]

    @parameters = { beta: run_hash["beta"], h: run_hash["h"] }
    @results = { order_parameter: run_hash["result"] }
  end

  def self.set_scale( num_places, min_start_at, max_finish_at )
    @@num_places = num_places
    @@min_start_at = min_start_at
    @@max_finish_at = max_finish_at
  end

  def draw_timeline
    x0 = $app.width / @@num_places * @place
    x1 = $app.width / @@num_places * (@place+1)

    calc_y = ->( time ) {
      return $app.height * (time - @@min_start_at).to_f / (@@max_finish_at - @@min_start_at).to_f
    }

    y0 = calc_y.call( @start_at )
    y1 = calc_y.call( @finish_at )

    $app.fill(255)
    $app.rect( x0, y0, x1-x0, y1-y0, 10 )
  end

  def draw_scatter_plot( range = { beta: [0.1,0.5], h:[-1.0, -0.6] }, t = 0, result_range = [0.0, 1.0] )
    x,y = range.map do |key, (min,max)|
      (@parameters[key] - min).to_f / (max - min)
    end
    x *= $app.width
    y *= $app.height

    if t > @start_at and t < @finish_at
      $app.fill(255,255,0)
      $app.ellipse( x, y, 40, 40 )
    elsif t >= @finish_at
      r = (@results[:order_parameter] - result_range[0]).to_f / ( result_range[1] - result_range[0] )
      from = $app.color( 0, 0, 255 )
      to = $app.color( 255, 0, 0 )
      c = $app.lerp_color( from, to, r )
      $app.fill( c )
      $app.ellipse( x, y, 20, 20 )
    else
      $app.fill(64)
      # $app.ellipse( x, y, 20, 20 )
      # do nothing
    end
  end
end

