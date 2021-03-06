(function() {
  window.bubbleScale = d3.scale.linear().domain([0, 36]).range([5, 40]);

  window.fontSizeScale = d3.scale.linear().domain([0, 36]).range([12, 20]);

  window.colorScale = d3.scale.linear().domain([0, 80]).range(['#0067e8', '#03f0d7']);

  window.barScale = d3.scale.linear().domain([0, 36]).range([10, 200]);

}).call(this);
