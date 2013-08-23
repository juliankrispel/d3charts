# Select container, insert SVG, define width and height
# and append g element 
svg = d3.select("#mapchart")
    .append("svg")
    .attr('width', '100%')
    .attr('height', '100%')
    .style('min-width', '400px')
    .attr('viewBox', '0 0 1000 600')
    .attr('preserveAspectRatio', 'xMidYMid')
    .attr('fill', '#353a41')

group = svg.append('g')

containerWidth = ->
    svg[0][0].offsetWidth

width = svg[0][0].offsetWidth
height = svg[0][0].offsetHeight

projection = d3.geo.mercator()
    .scale(170)

d3.json "json/world.topo.json", (error, world) ->
    console.log world
    subunits = topojson.feature world, world.objects.countries



    path = d3.geo.path().projection projection

    group.append('path')
        .datum( subunits )
        .attr( 'd', path )

    d3.json "json/exchanges.normal.json", (error, exchanges) ->
        group.selectAll('circle')
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

        group.selectAll('.market-label')
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

