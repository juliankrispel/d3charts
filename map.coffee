# Config
width = 700
height = 400

# Scale 
bubbleScale = d3.scale.linear()
    .domain([0, 100])
    .range([5, 60])

fontSizeScale = d3.scale.linear()
    .domain([0, 100])
    .range([12, 30])

# Color Scale
colorScale = d3.scale.linear()
    .domain([0, 80])
    .range(['#0067e8', '#03f0d7'])

# Select container, insert SVG, define width and height
# and append g element 
svg = d3.select("#mapchart")
    .append("svg")
    .attr("width", width)
    .attr('fill', '#000')
    .attr("height", height)


d3.json "json/world.topo.json", (error, world) ->
    subunits = topojson.feature world, world.objects.countries


    projection = d3.geo.mercator()
        .bubbleScale(120)
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

    null

