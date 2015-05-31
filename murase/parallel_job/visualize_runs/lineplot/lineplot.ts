/// <reference path="../DefinitelyTyped/d3/d3.d.ts" />
/// <reference path="../DefinitelyTyped/jquery/jquery.d.ts" />
/// <reference path="../DefinitelyTyped/jqueryui/jqueryui.d.ts" />

interface ParameterSet {
  id: number;
  point: number[];
  result: number;
  num_runs: number;
}

interface Domains {
  x: number[];
  y: number[];
}

class LinePlot {
  
  private svg: D3.Selection;
  private width: number;
  private height: number;
  private xScale: D3.Scale.LinearScale;
  private yScale: D3.Scale.LinearScale;
  
  constructor(elementId: string) {
    var margin = {top: 20, right: 20, bottom: 30, left: 40};
    this.width = 960 - margin.left - margin.right,
    this.height = 600 - margin.top - margin.bottom;
    
    this.xScale = d3.scale.linear().range([0,this.width]);
    this.yScale = d3.scale.linear().range([this.height,0]);
    
    this.svg = d3.select(elementId).append("svg")
      .attr("width", this.width + margin.left + margin.right)
      .attr("height", this.height + margin.top + margin.bottom)
      .append("g")
        .attr("transform", "translate("+margin.left+","+margin.top+")");
  }
  
  public build(url: string) {
    d3.json('/domain?x=x2', (error: any, data: Domains) => {
      
      this.xScale.domain( data.x );
      this.yScale.domain( data.y );
      
      this.buildAxis();
      
      var path = this.svg.append("path").attr("id", "dataline").attr("class", "dataline");
      this.update(0,0);
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
      .text("Result");
  }

  public update(x0:number, x1:number) {
    var url = this.buildUrlFilteredData(x0,x1);
    d3.json(url, (error: any, data: ParameterSet[]) => {
      var points = this.svg.selectAll("circle.point")
        .data(data);
      points.exit().remove();
      points.enter().append('circle');
      this.setCircleStyles( points );

      var path = this.svg.select("path#dataline");
      path.datum(data);
      this.drawLine(path);
    });
  }
  
  private buildUrlFilteredData(x0: number, x1: number) {
    var url = `/filter?x0=${x0}&x1=${x1}`;
    return url;
  }

  private setCircleStyles( points: D3.Selection ) {
    var tooltip = d3.select('span#tooltip');
    points
      .attr("class", "point")
      .attr("cx", (d:ParameterSet) => { return this.xScale(d.point[2] ); })
      .attr("cy", (d:ParameterSet) => { return this.yScale(d.result); })
      .attr("r", 4)
      .style("opacity", .8)
      .on("mouseover", function(d:ParameterSet) {
        d3.select(this).style("opacity", 1);
        var t: string =
          `id: ${d.id},
           point: ${d.point},
           result: ${d.result},
           #runs: ${d.num_runs}
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
  }
  
  private drawLine( path: D3.Selection ) {
      var line = d3.svg.line()
        .x( (d:ParameterSet)=>{return this.xScale(d.point[2]);} )
        .y( (d:ParameterSet)=>{return this.yScale(d.result);} );
      path.attr("d", line);
  }
}

class Slider {
  private sliderDiv: JQuery;
  private spinner: JQuery;
  private min: number;
  private max: number;
  constructor(parentElementId: string, id: string, min: number, max: number) {
    var parent = $(parentElementId).append(`<div id="${id}"></div>`);
    var sliderId = `${id}-slider`;
    var spinnerId = `${id}-spinner`;
    parent
      .append(`<label for="${spinnerId}">${id}</label>`)
      .append(`<input id="${spinnerId}"></select>`);
    parent.append(`<div id="${sliderId}"></div>`);
    this.sliderDiv = $('#'+sliderId);
    this.spinner = $('#'+spinnerId);
    this.max = max;
    this.min = min;

    this.sliderDiv.slider({
      orientation: "horizontal",
      range: false,
      min: this.min,
      max: this.max,
      step: 1,
      value: this.min
    }).slider("value", this.min);

    this.spinner.spinner({
      min: this.min,
      max: this.max,
      step: 1,
      page: Math.ceil( (this.max - this.min) / 10),
    }).spinner("value", this.min);

    this.setOnChange( (n:number) => {} );
  }

  public setOnChange( f:(sliderVal:number)=>void ) {
    var onSliderChange = (event, ui) => {
      var val = ui.value;
      this.spinner.spinner("value", val);
      f(val);
    }
    var onSpinnerChange = (event, ui) => {
      var val = ui.value;
      this.sliderDiv.slider("value", val);
      f(val);
    }
    this.sliderDiv.slider({
      change: onSliderChange,
      slide: onSliderChange
    });
    this.spinner.spinner({
      chagne: onSpinnerChange,
      spin: onSpinnerChange
    });
  }
  
  public getVal(): number {
    return this.spinner.spinner("value");
  }
}

document.body.onload = function() {
  var plot = new LinePlot('#plot');
  // plot.build('parameter_sets.json');
  plot.build('/filter');
  var slider0 = new Slider('#sliders', 'x0', 0, 2);
  var slider1 = new Slider('#sliders', 'x1', 0, 9);
  slider0.setOnChange( (n:number) => { plot.update(n, slider1.getVal()); } );
  slider1.setOnChange( (n:number) => { plot.update(slider0.getVal(), n); } );
}
