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

    g = svg.selectAll(".arc")
        .data(pie(data.exchanges))
        .enter()
        .append("g")
        .attr("class", "arc")

    g.append("path")
        .attr("d", arc)
        .style "fill", (d) -> 
            colorScale d.value

    g.append("text")
        .attr("transform", (d) ->
            "translate(" + arc.centroid(d) + ")")
        .attr("dy", ".35em")
        .style('text-anchor', "middle")
        .style('font-size', (d) -> 
            fontSizeScale(d.data[3]) + 'px')
        .style('font-weight', 'bold')
        .style('fill', (d) -> 
            color = d3.rgb(colorScale(d.data[3]))
            color.darker(2)
        )
        .text (d) ->
            d.data[0]
        .append('tspan')
        .attr('y', (d) -> fontSizeScale(d.data[3]) * 1.3 )
        .attr('x', 0 )
        .style('font-size', (d) -> fontSizeScale(d.data[3]) - 1 + 'px')
        .text((d) -> d.data[3] + '%')
        .style('fill', (d) ->
            color = d3.rgb(colorScale(d.data[3]))
            color.darker(1)
        )
