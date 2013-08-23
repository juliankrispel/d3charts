(function() {
  var div;

  div = d3.select("#horizontalbarchart");

  d3.json("json/exchanges.normal.json", function(error, data) {
    var barWidth;
    barWidth = 100 / data.exchanges.length;
    div.selectAll('div').data(data.exchanges).enter().append('div').style('width', barWidth + '%').attr('class', 'barchart__bar').style('height', function(d) {
      return barScale(d[3]) + 'px';
    }).style('margin-top', function(d) {
      return 200 - barScale(d[3]) + 'px';
    }).style('background', function(d) {
      return colorScale(d[3]);
    }).append('span').attr('class', 'barchart__bar__caption').text(function(d) {
      return d[0];
    });
    return div.selectAll('.barchart__bar__percent');
  });

}).call(this);
