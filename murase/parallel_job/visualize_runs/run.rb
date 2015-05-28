class Run

  attr_reader :id, :start_at, :finish_at, :result, :parent_ps_id

  def initialize( run_hash )
    @id = run_hash["id"]
    @place = run_hash["placeId"]
    @start_at = run_hash["startAt"]
    @finish_at = run_hash["finishAt"]
    @parent_ps_id = run_hash["parentPSId"]
    @result = run_hash["result"]
  end

  def draw_timeline( num_places, time_scale )
    x0 = $app.width / num_places * @place
    x1 = $app.width / num_places * (@place+1)

    calc_y = ->( time ) {
      return $app.height * (time - time_scale[0]).to_f / (time_scale[1] - time_scale[0]).to_f
    }

    y0 = calc_y.call( @start_at )
    y1 = calc_y.call( @finish_at )

    $app.fill(255)
    $app.rect( x0, y0, x1-x0, y1-y0, 10 )
  end
end

