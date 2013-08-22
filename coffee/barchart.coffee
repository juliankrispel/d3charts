#Config
width = 500
height = 400
radius = Math.min(width, height) / 2

arc = d3.svg.arc().outerRadius(radius - 10).innerRadius(0)
pie = d3.layout.pie()
    .sort(null)
    .value((d) ->
      d[3]
    )

svg = d3
    .select("#piechart")
    .append("svg")
    .attr("width", width)
    .attr("height", height)
    .append("g")
    .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")")

d3.json "json/exchanges.normal.json", (error, data) ->
    console.log data

