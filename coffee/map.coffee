getBoundingBox = (elements) ->

    left = Infinity
    top = Infinity
    bottom = -Infinity
    right = -Infinity

    _(elements).each((element) -> 
        bbox = element.getBBox()
        xleft = bbox.x - bbox.width/2
        xright = bbox.x + bbox.width
        ytop = bbox.y
        ybottom = bbox.y + bbox.height

        left = xleft if xleft < left
        top = ytop  if ytop < top
        right = xright  if xright > right
        bottom = ybottom  if ybottom > bottom
    )

    [[left, top], [right, bottom]]

# Select container, insert SVG, define width and height
# and append g element 
svg = d3.select("#mapchart")
    .append("svg")
    .attr('width', '1000px')
    .attr('height', '700px')
    .style('width', '100%')
    .style('height', '100%')
    .style('min-width', '400px')
    .attr('viewBox', '0 0 1000 700')
    .attr('preserveAspectRatio', 'xMidYMin')
    .attr('fill', '#353a41')

window.group = svg.append('g')

containerSize = ->
    [
        svg[0][0].offsetWidth,
        svg[0][0].offsetHeight
    ]

resize = ->
    bbox = group[0][0].getBBox()
    console.log bbox
    aspect =  bbox.width / bbox.height
    width = containerSize()[0]
    svg.attr('height', width / aspect)

    #window.onresize = () -> resize()

width = svg[0][0].offsetWidth
height = svg[0][0].offsetHeight

projection = d3.geo.mercator()
    .scale(170)

d3.json "json/world.topo.json", (error, world) ->
    #    projection = fitProjection( projection, world.objects.countries.geometries, [[0, 0], [100, 100]], true)
    subunits = topojson.feature world, world.objects.countries

    window.path = d3.geo.path().projection projection

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
            .attr('x', (d) -> 
                p = projection([d[2], d[1]])
                bubbleScale(d[3]) + 5 + p[0]
            )
            .attr('y', (d) ->
                p = projection([d[2], d[1]])
                fontSizeScale(d[3]) / 2 + p[1]
            )
            .style('font-size', (d) -> fontSizeScale(d[3]) + 'px')
            .style('fill', (d) -> colorScale(d[3]))
            .text((d) -> 
                d[3] + '%'
            )
            .append('tspan')
            .attr('y', (d) ->
                p = projection([d[2], d[1]])
                p[1] - fontSizeScale(d[3]) / 2 + 5
            )
            .attr('x', (d) -> 
                p = projection([d[2], d[1]])
                bubbleScale(d[3]) + 5 + p[0]
            )
            .style('font-size', (d) -> fontSizeScale(d[3]) - 1 + 'px')
            .text (d) -> d[0]


        boundingElements = []

        _(group.selectAll('circle')[0]).each((d)->
            boundingElements.push d
        )

        _(group.selectAll('text')[0]).each((d) ->
            boundingElements.push d
        )

        # using the path determine the bounds of the current map and use 
        # these to determine better values for the scale and translation
        b = getBoundingBox(boundingElements)
        boundsWidth = b[1][0] - b[0][0]
        boundsHeight = b[1][1] - b[0][1]

        #        boundingBox = group.append('rect')
        #            .style('fill', 'rgba(255,0,0,.3)')
        #            .attr('x', b[0][0])
        #            .attr('y', b[0][1])
        #            .attr('width', boundsWidth)
        #            .attr('height', boundsHeight)

        hscale  = scale*width  / (b[1][0] - b[0][0])
        vscale  = scale*height / (b[1][1] - b[0][1])
        scale   = (hscale < vscale) ? hscale : vscale
        offset  = [width - (b[0][0] + b[1][0])/2, height - (b[0][1] + b[1][1])/2]

        dimensions = group[0][0].getBBox()

        s = .95 / Math.max((b[1][0] - b[0][0]) / dimensions.width + 20, (b[1][1] - b[0][1]) / dimensions.height)
        t = [(dimensions.width - s * (b[1][0] + b[0][0])) / 2, (dimensions.height - s * (b[1][1] + b[0][1])) / 2]

        group.transition().duration(750).attr("transform",
            "translate(" + projection.translate() + ")" + "scale(" + .95 / Math.max((b[1][0] - b[0][0]) / dimensions.width, (b[1][1] - b[0][1]) / dimensions.height) + ")" + "translate(" + -(b[1][0] + b[0][0]) / 2 + "," + -(b[1][1] + b[0][1]) / 2 + ")")



            #        window.onresize = ->
            #            projection.translate([height / 2, width / 2])
            #            group.selectAll('path')
            #                .attr('d', d3.geo.path().projection(projection))
            #
    
            #    b = group.select('path')[0][0].getBBox()
            #    console.log(b)
            #    g.transition().duration(750).attr("transform",
            #        "translate(" + projection.translate() + ")"
            #        + "scale(" + .95 / Math.max((b[1][0] - b[0][0]) / width, (b[1][1] - b[0][1]) / height) + ")"
            #        + "translate(" + -(b[1][0] + b[0][0]) / 2 + "," + -(b[1][1] + b[0][1]) / 2 + ")")
            #
    null


