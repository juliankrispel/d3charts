(function() {
  var arc, height, pie, radius, svg, width;

  svg = d3.select("#piechart").append("svg").attr("width", '100%').attr("height", '100%').style('min-width', '400px').attr('viewBox', '0 0 1000 600').attr('preserveAspectRatio', 'xMidYMid');

  width = svg[0][0].offsetWidth;

  height = svg[0][0].offsetHeight;

  radius = height / 2;

  arc = d3.svg.arc().outerRadius(radius - 10).innerRadius(0);

  pie = d3.layout.pie().sort(null).value(function(d) {
    return d[3];
  });

  svg = svg.append("g").attr("transform", "translate(" + 500 + "," + height / 2 + ")");

  d3.json("json/exchanges.normal.json", function(error, data) {
    var g;
    g = svg.selectAll(".arc").data(pie(data.exchanges)).enter().append("g").attr("class", "arc");
    g.append("path").attr("d", arc).style("fill", function(d) {
      return colorScale(d.value);
    });
    return g.append("text").attr("transform", function(d) {
      return "translate(" + arc.centroid(d) + ")";
    }).attr("dy", ".35em").style('text-anchor', "middle").style('font-size', function(d) {
      return fontSizeScale(d.data[3]) + 'px';
    }).style('font-weight', 'bold').style('fill', function(d) {
      var color;
      color = d3.rgb(colorScale(d.data[3]));
      return color.darker(2);
    }).text(function(d) {
      return d.data[0];
    }).append('tspan').attr('y', function(d) {
      return fontSizeScale(d.data[3]) * 1.3;
    }).attr('x', 0).style('font-size', function(d) {
      return fontSizeScale(d.data[3]) - 1 + 'px';
    }).text(function(d) {
      return d.data[3] + '%';
    }).style('fill', function(d) {
      var color;
      color = d3.rgb(colorScale(d.data[3]));
      return color.darker(1);
    });
  });

}).call(this);
