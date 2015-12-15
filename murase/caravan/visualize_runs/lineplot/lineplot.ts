/// <reference path="../DefinitelyTyped/d3/d3.d.ts" />
/// <reference path="../DefinitelyTyped/jquery/jquery.d.ts" />
/// <reference path="../DefinitelyTyped/jqueryui/jqueryui.d.ts" />

interface ParameterSet {
  id: number;
  point: number[];
  result: number;
  num_runs: number;
}

interface Domain {
  min: number;
  max: number;
}

interface Domains {
  numParams: number;
  paramDomains: Domain[];  // size: numParams
  numOutputs: number;
  outputDomains: Domain[]; // size: numOutputs
}

function getMinPoint(domains: Domains): number[] {
  var minPoint = new Array( domains.numParams );
  for( var i=0; i < domains.numParams; i++) {
    minPoint[i] = domains.paramDomains[i].min;
  }
  return minPoint;
}

class LinePlot {

  private svg: d3.Selection<any>;
  private width: number;
  private height: number;
  private xScale: d3.scale.Linear<number,number>;
  private yScale: d3.scale.Linear<number,number>;
  private xAxis: d3.Selection<any>;
  private yAxis: d3.Selection<any>;
  private domains: Domains;
  private xKey: number;
  private yKey: number;
  
  constructor(elementId: string, domains: Domains) {
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
    this.xAxis = this.svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + this.height + ")");
    this.yAxis = this.svg.append("g")
      .attr("class", "y axis");
    this.yAxis.append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text("Result");

    this.domains = domains;
  }

  public build(xKey: number, yKey: number) {
    this.xKey = xKey;
    this.yKey = yKey;

    this.buildAxis();
    var path = this.svg.append("path").attr("id", "dataline").attr("class", "dataline");
    this.update( getMinPoint(this.domains) );
  }
  
  private buildAxis() {
    var xDomain = this.domains.paramDomains[this.xKey];
    this.xScale.domain([xDomain.min, xDomain.max]);
    var yDomain = this.domains.outputDomains[this.yKey];
    this.yScale.domain([yDomain.min, yDomain.max]);

    var xAxisBuilder = d3.svg.axis().scale(this.xScale).orient("bottom");
    var yAxisBuilder = d3.svg.axis().scale(this.yScale).orient("left");
    this.xAxis.call(xAxisBuilder);
    this.yAxis.call(yAxisBuilder);
  }

  public update( point: number[] ) {
    var url = this.buildUrlFilteredData(point, this.xKey);
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
  
  private buildUrlFilteredData( point: number[], xkey: number ): string {
    var params = new Array();
    for( var i = 0; i < point.length; i++ ) {
      if( i == xkey ) continue;
      params.push( `x${i}=${point[i]}` );
    }
    var url = "/filter?" + params.join('&');
    return url;
  }

  private setCircleStyles( points: d3.Selection<any> ) {
    var tooltip = d3.select('span#tooltip');
    points
      .attr("class", "point")
      .attr("cx", (d:ParameterSet) => { return this.xScale(d.point[this.xKey] ); })
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
  
  private drawLine( path: d3.Selection<any> ) {
      var line = d3.svg.line<ParameterSet>()
        .x( (d:ParameterSet)=>{return this.xScale(d.point[this.xKey]);} )
        .y( (d:ParameterSet)=>{return this.yScale(d.result);} );
      path.attr("d", line);
  }
}

class Selector {
  
  private select: JQuery;
  
  constructor(selectElementSelector: string, options: string[]) {
    var tags = "";
    options.forEach( (val:string,idx: number) => {
      var option = `<option value="${val}">${val}</option>`;
      tags += option;
    });
    this.select = $(selectElementSelector)
    this.select.append(tags);
  }
  
  public setOnChange( f:(selected:string)=>void ) {
    this.select.change( function() {
      var selected = $(this).val();
      f(selected);
    });
  }
  
  public Trigger() {
    this.select.trigger('change');
  }
}

class Slider {
  private sliderDiv: JQuery;
  private fieldDiv: JQuery;
  private min: number;
  private max: number;
  constructor(parentElementId: string, id: string, min: number, max: number) {
    var parent = $(parentElementId).append(`<div id="${id}"></div>`);
    var fieldId = `${id}-text`;
    var sliderId = `${id}-slider`;
    parent
      .append(`<label for="${fieldId}">${id}</label>`)
      .append(`<input type="text" id="${fieldId}" disabled="disabled"></input>`);
    parent.append(`<div id="${sliderId}"></div>`);
    this.sliderDiv = $('#'+sliderId);
    this.fieldDiv = $('#'+fieldId);
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
    this.fieldDiv.val( this.sliderDiv.slider('value').toString() );

    this.setOnChange( (n:number) => {} );
  }

  public setOnChange( f:(sliderVal:number)=>void ) {
    var onSliderChange = (event, ui) => {
      var val = ui.value;
      this.fieldDiv.val(val);
      f(val);
    }
    this.sliderDiv.slider({
      change: onSliderChange,
      slide: onSliderChange
    });
  }
  
  public getVal(): number {
    return this.sliderDiv.slider('value');
  }
  
  public disable() {
    this.sliderDiv.slider("disable");
  }
  
  public enable() {
    this.sliderDiv.slider("enable");
  }
}

document.body.onload = function() {
  var url = '/domains';
  d3.json(url, (error: any, domains: Domains) => {
    var plot = new LinePlot('#plot', domains);
    var xKeys = domains.paramDomains.map((v:Domain,idx:number) => { return idx.toString(); });
    var select_x = new Selector('#select_x #xkey', xKeys);
    var select_series = new Selector('#select_series #series_key', xKeys);
    
    var sliders: Slider[] = [];
    for( var i=0; i < domains.numParams; i++) {
      var domain = domains.paramDomains[i];
      var slider = new Slider('#sliders', `x${i}`, domain.min, domain.max);
      sliders.push( slider );
    }

    var slidersToPoint = ():number[] => {
      var point: number[] = new Array( sliders.length );
      for( var i=0; i < sliders.length; i++ ) {
        point[i] = sliders[i].getVal();
      }
      return point;
    }
    select_x.setOnChange( (selected:string) => {
      var xKey = Number(selected);
      for( var i=0; i < sliders.length; i++) {
        if( i == xKey ) { sliders[i].disable(); }
        else { sliders[i].enable(); }
      }
      plot.build( xKey, 0 );
      plot.update( slidersToPoint() );
    });
    select_series.setOnChange( (selected:string) => {
      var xKey = Number(selected);
      for( var i=0; i < sliders.length; i++) {
        if( i == xKey ) { sliders[i].disable(); }
        else { sliders[i].enable(); }
      }
      plot.build( xKey, 0 );
      plot.update( slidersToPoint() );
    })
    for( var i=0; i < sliders.length; i++ ) {
      sliders[i].setOnChange( (n:number) => { plot.update( slidersToPoint() ); } );
    }

    select_x.Trigger();
  });
}
