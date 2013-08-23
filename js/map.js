(function() {
  var containerWidth, group, height, projection, svg, width;

  svg = d3.select("#mapchart").append("svg").attr('width', '100%').attr('height', '100%').style('min-width', '400px').attr('viewBox', '0 0 1000 600').attr('preserveAspectRatio', 'xMidYMid').attr('fill', '#353a41');

  group = svg.append('g');

  containerWidth = function() {
    return svg[0][0].offsetWidth;
  };

  width = svg[0][0].offsetWidth;

  height = svg[0][0].offsetHeight;

  projection = d3.geo.mercator().scale(170);

  d3.json("json/world.topo.json", function(error, world) {
    var path, subunits;
    subunits = topojson.feature(world, world.objects.countries);
    path = d3.geo.path().projection(projection);
    group.append('path').datum(subunits).attr('d', path);
    d3.json("json/exchanges.normal.json", function(error, exchanges) {
      group.selectAll('circle').data(exchanges.exchanges).enter().append('circle').attr('name', function(d) {
        return d[0];
      }).attr('cx', function(d) {
        var p;
        p = projection([d[2], d[1]]);
        return p[0];
      }).attr('cy', function(d) {
        var p;
        p = projection([d[2], d[1]]);
        return p[1];
      }).attr('r', function(d) {
        return bubbleScale(d[3]);
      }).style('opacity', .5).style('fill', function(d) {
        return colorScale(d[3]);
      });
      return group.selectAll('.market-label').data(exchanges.exchanges).enter().append('text').attr('class', 'market-label').attr('dy', '.35em').attr('x', function(d) {
        return bubbleScale(d[3]) + 5;
      }).attr('y', function(d) {
        return -fontSizeScale(d[3]) / 2;
      }).attr('transform', function(d) {
        return 'translate(' + projection([d[2], d[1]]) + ')';
      }).style('font-size', function(d) {
        return fontSizeScale(d[3]) + 'px';
      }).style('fill', function(d) {
        return colorScale(d[3]);
      }).text(function(d) {
        return d[3] + '%';
      }).append('tspan').attr('y', function(d) {
        return fontSizeScale(d[3]) / 2 + 5;
      }).attr('x', function(d) {
        return bubbleScale(d[3]) + 5;
      }).style('font-size', function(d) {
        return fontSizeScale(d[3]) - 1 + 'px';
      }).text(function(d) {
        return d[0];
      });
    });
    return null;
  });

}).call(this);
