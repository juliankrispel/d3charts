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
      var b, boundingElements, boundsHeight, boundsWidth, dimensions, force, labels, s, size, t;
      labels = [];
      size = containerSize();
      _(exchanges.exchanges).each(function(exchange) {
        var p;
        p = projection([exchange[2], exchange[1]]);
        return labels.push({
          lat: p[0],
          long: p[1],
          name: exchange[0],
          value: exchange[3]
        });
      });
      force = d3.layout.force().nodes(labels).links([]).gravity(0).size([1000, 700]).start();
      force.on("tick", function(e) {
        var k;
        k = .1 * e.alpha;
        _(labels).each(function(label) {
          label.x += (label.lat - label.x) * k;
          return label.y += (label.long - label.y) * k;
        });
        group.selectAll('circle').attr('cx', function(d) {
          return d.x;
        }).attr('cy', function(d) {
          return d.y;
        });
        return group.selectAll('text').attr('x', function(d) {
          return d.x + bubbleScale(d.value) + 4;
        }).attr('y', function(d) {
          return d.y;
        });
      });
      group.selectAll('.label').data(labels).enter().append('g').attr('class', 'label');
      group.selectAll('.label').append('circle').attr('class', 'force-node').attr('name', function(d) {
        return d.name;
      }).attr('r', function(d) {
        return bubbleScale(d.value);
      }).attr('cx', function(d) {
        return d.x;
      }).attr('cy', function(d) {
        return d.y;
      }).style('opacity', .5).style('fill', function(d) {
        return colorScale(d.value);
      });
      group.selectAll('.label').append('text').attr('class', 'market-label force-node').attr('dy', '.35em').style('font-size', function(d) {
        return fontSizeScale(d.value) + 'px';
      }).style('fill', function(d) {
        return colorScale(d.value);
      }).text(function(d) {
        return d.value + '%';
      }).attr('cx', function(d) {
        return d.x;
      }).attr('cy', function(d) {
        return d.y;
      }).append('tspan').style('font-size', function(d) {
        return fontSizeScale(d.value) - 1 + 'px';
      }).text(function(d) {
        return d.name;
      });
      boundingElements = [];
      _(group.selectAll('circle')[0]).each(function(d) {
        return boundingElements.push(d);
      });
      _(group.selectAll('text')[0]).each(function(d) {
        return boundingElements.push(d);
      });
      return null;
      b = getBoundingBox(boundingElements);
      boundsWidth = b[1][0] - b[0][0];
      boundsHeight = b[1][1] - b[0][1];
      dimensions = group[0][0].getBBox();
      s = .95 / Math.max((b[1][0] - b[0][0]) / dimensions.width + 20, (b[1][1] - b[0][1]) / dimensions.height);
      t = [(dimensions.width - s * (b[1][0] + b[0][0])) / 2, (dimensions.height - s * (b[1][1] + b[0][1])) / 2];
      return group.transition().duration(750).attr("transform", "translate(" + projection.translate() + ")" + "scale(" + .95 / Math.max((b[1][0] - b[0][0]) / dimensions.width, (b[1][1] - b[0][1]) / dimensions.height) + ")" + "translate(" + -(b[1][0] + b[0][0]) / 2 + "," + -(b[1][1] + b[0][1]) / 2 + ")");
    });
    return null;
  });

}).call(this);
