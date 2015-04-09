class Run

  def initialize( run_hash )
    @place = run_hash["placeId"]
    @start_at = run_hash["startAt"]
    @finish_at = run_hash["finishAt"]
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
end

