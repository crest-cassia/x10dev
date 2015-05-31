/// <reference path="../DefinitelyTyped/d3/d3.d.ts" />

interface Run {
  id: number;
  parentPSId: number;
  seed: number;
  result: number;
  placeId: number;
  startAt: number;
  finishAt: number;
}

class BoxPlot {
  
  private svg: D3.Selection;
  private width: number;
  private height: number;
  private xScale: D3.Scale.OrdinalScale;
  private yScale: D3.Scale.LinearScale;
  
  constructor(elementId: string) {
    var margin = {top: 20, right: 20, bottom: 30, left: 40};
    this.width = 1500 - margin.left - margin.right,
    this.height = 2000 - margin.top - margin.bottom;
    
    this.xScale = d3.scale.ordinal().rangeRoundBands([0,this.width], .1, 1);
    this.yScale = d3.scale.linear().range([0,this.height]);
    
    this.svg = d3.select(elementId).append("svg")
      .attr("width", this.width + margin.left + margin.right)
      .attr("height", this.height + margin.top + margin.bottom)
      .append("g")
        .attr("transform", "translate("+margin.left+","+margin.top+")");
  }
  
  public build(url: string) {
    d3.json(url, (error: any, data: Run[]):void => {
      
      this.xScale.domain( data.map( (d)=>{ return d.placeId;}).sort( (a,b) => {return a-b;} ) );
      this.yScale.domain([
        d3.min(data, (d)=>{ return d.startAt;}),
        d3.max(data, (d)=>{ return d.finishAt;})
      ]);
      
      this.buildAxis();
      
      var tooltip = d3.select('span#tooltip');
      
      this.svg.selectAll(".bar")
        .data(data)
      .enter().append("rect")
        .attr("class", "bar")
        .attr("x", (d) => { return this.xScale(d.placeId); })
        .attr("width", this.xScale.rangeBand())
        .attr("y", (d) => { return this.yScale(d.startAt); })
        .attr("height", (d) => { return this.yScale(d.finishAt - d.startAt); })
        .attr("rx", 4).attr("ry", 4)
        .style("opacity", .8)
        .on("mouseover", function(d) {
          d3.select(this).style("opacity", 1);
          var t: string =
            `id: ${d.id},
             time: ${d.startAt} - ${d.finishAt},
             place: ${d.placeId},
             parentPSId: ${d.parentPSId},
             result: ${d.result}
             `;
          tooltip.style("visibility", "visible")
            .text(t);
        })
        .on("mousemove", function(d){
          tooltip
            .style("top", (d3.event.pageY-20)+"px")
            .style("left", (d3.event.pageX+10)+"px");
        })
        .on("mouseout", function(d){
          d3.select(this).style("opacity", .8);
          tooltip.style("visibility", "hidden");
        });
    });
  }
  
  private buildAxis() {
    var xAxis = d3.svg.axis().scale(this.xScale).orient("bottom");
    var yAxis = d3.svg.axis().scale(this.yScale).orient("left");
    this.svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + this.height + ")")
      .call(xAxis);
    this.svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
    .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text("Time");
  }  
}

document.body.onload = function() {
  var box = new BoxPlot('#plot');
  box.build('/runs');
}
