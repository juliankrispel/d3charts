# Config
width = 700
height = 400

# Scale 

# Select container, insert SVG, define width and height
# and append g element 
svg = d3.select("#map")
    .append("svg")
    .attr("width", width)
    .attr('fill', '#353a41')
    .attr("height", height)

d3.json "json/world.topo.json", (error, world) ->
    subunits = topojson.feature world, world.objects.countries

    projection = d3.geo.mercator()
        .scale(120)
        .translate [width / 2, height / 2]

    path = d3.geo.path().projection projection

    svg.append('path')
        .datum( subunits )
        .attr( 'd', path )

    d3.json "json/exchanges.normal.json", (error, exchanges) ->
        svg.selectAll('circle')
            .data(exchanges.exchanges)
            .enter()
            .append('circle')
            .attr('name', (d) -> d[0])
            .attr('cx', (d) -> 
                p = projection([d[2], d[1]])
                p[0]
            )
            .attr('cy', (d) -> 
                p = projection([d[2], d[1]])
                p[1]
            )
            .attr('r', (d) -> bubbleScale(d[3]))
            .style('opacity', .5)
            .style('fill', (d) -> 
                colorScale(d[3])
            )

        svg.selectAll('.market-label')
            .data(exchanges.exchanges)
            .enter()
            .append('text')
            .attr('class', 'market-label')
            .attr('dy', '.35em')
            .attr('x', (d) -> bubbleScale(d[3]) + 5 )
            .attr('y', (d) -> - fontSizeScale(d[3]) / 2 )
            .attr('transform', (d) -> 'translate(' + projection([d[2], d[1]]) + ')')
            .style('font-size', (d) -> fontSizeScale(d[3]) + 'px')
            .style('fill', (d) -> colorScale(d[3]))
            .text((d) -> 
                d[3] + '%'
            )
            .append('tspan')
            .attr('y', (d) -> fontSizeScale(d[3]) / 2 + 5 )
            .attr('x', (d) -> bubbleScale(d[3]) + 5 )
            .style('font-size', (d) -> fontSizeScale(d[3]) - 1 + 'px')
            .text (d) -> d[0]

    null

