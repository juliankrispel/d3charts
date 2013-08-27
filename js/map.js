(function() {
  var containerSize, getBoundingBox, height, projection, resize, svg, width;

  getBoundingBox = function(elements) {
    var bottom, left, right, top;
    left = Infinity;
    top = Infinity;
    bottom = -Infinity;
    right = -Infinity;
    _(elements).each(function(element) {
      var bbox, xleft, xright, ybottom, ytop;
      bbox = element.getBBox();
      xleft = bbox.x - bbox.width / 2;
      xright = bbox.x + bbox.width;
      ytop = bbox.y;
      ybottom = bbox.y + bbox.height;
      if (xleft < left) {
        left = xleft;
      }
      if (ytop < top) {
        top = ytop;
      }
      if (xright > right) {
        right = xright;
      }
      if (ybottom > bottom) {
        return bottom = ybottom;
      }
    });
    return [[left, top], [right, bottom]];
  };

  svg = d3.select("#mapchart").append("svg").attr('width', '1000px').attr('height', '700px').style('width', '100%').style('height', '100%').style('min-width', '400px').attr('viewBox', '0 0 1000 700').attr('preserveAspectRatio', 'xMidYMin').attr('fill', '#353a41');

  window.group = svg.append('g');

  containerSize = function() {
    return [svg[0][0].offsetWidth, svg[0][0].offsetHeight];
  };

  resize = function() {
    var aspect, bbox, width;
    bbox = group[0][0].getBBox();
    console.log(bbox);
    aspect = bbox.width / bbox.height;
    width = containerSize()[0];
    return svg.attr('height', width / aspect);
  };

  width = svg[0][0].offsetWidth;

  height = svg[0][0].offsetHeight;

  projection = d3.geo.mercator().scale(170);

  d3.json("json/world.topo.json", function(error, world) {
    var subunits;
    subunits = topojson.feature(world, world.objects.countries);
    window.path = d3.geo.path().projection(projection);
    group.append('path').datum(subunits).attr('d', path);
    d3.json("json/exchanges.normal.json", function(error, exchanges) {
      var b, boundingElements, boundsHeight, boundsWidth, dimensions, hscale, offset, s, scale, t, vscale, _ref;
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
      group.selectAll('.market-label').data(exchanges.exchanges).enter().append('text').attr('class', 'market-label').attr('dy', '.35em').attr('x', function(d) {
        var p;
        p = projection([d[2], d[1]]);
        return bubbleScale(d[3]) + 5 + p[0];
      }).attr('y', function(d) {
        var p;
        p = projection([d[2], d[1]]);
        return fontSizeScale(d[3]) / 2 + p[1];
      }).style('font-size', function(d) {
        return fontSizeScale(d[3]) + 'px';
      }).style('fill', function(d) {
        return colorScale(d[3]);
      }).text(function(d) {
        return d[3] + '%';
      }).append('tspan').attr('y', function(d) {
        var p;
        p = projection([d[2], d[1]]);
        return p[1] - fontSizeScale(d[3]) / 2 + 5;
      }).attr('x', function(d) {
        var p;
        p = projection([d[2], d[1]]);
        return bubbleScale(d[3]) + 5 + p[0];
      }).style('font-size', function(d) {
        return fontSizeScale(d[3]) - 1 + 'px';
      }).text(function(d) {
        return d[0];
      });
      boundingElements = [];
      _(group.selectAll('circle')[0]).each(function(d) {
        return boundingElements.push(d);
      });
      _(group.selectAll('text')[0]).each(function(d) {
        return boundingElements.push(d);
      });
      b = getBoundingBox(boundingElements);
      boundsWidth = b[1][0] - b[0][0];
      boundsHeight = b[1][1] - b[0][1];
      hscale = scale * width / (b[1][0] - b[0][0]);
      vscale = scale * height / (b[1][1] - b[0][1]);
      scale = (_ref = hscale < vscale) != null ? _ref : {
        hscale: vscale
      };
      offset = [width - (b[0][0] + b[1][0]) / 2, height - (b[0][1] + b[1][1]) / 2];
      dimensions = group[0][0].getBBox();
      s = .95 / Math.max((b[1][0] - b[0][0]) / dimensions.width + 20, (b[1][1] - b[0][1]) / dimensions.height);
      t = [(dimensions.width - s * (b[1][0] + b[0][0])) / 2, (dimensions.height - s * (b[1][1] + b[0][1])) / 2];
      return group.transition().duration(750).attr("transform", "translate(" + projection.translate() + ")" + "scale(" + .95 / Math.max((b[1][0] - b[0][0]) / dimensions.width, (b[1][1] - b[0][1]) / dimensions.height) + ")" + "translate(" + -(b[1][0] + b[0][0]) / 2 + "," + -(b[1][1] + b[0][1]) / 2 + ")");
    });
    return null;
  });

}).call(this);
