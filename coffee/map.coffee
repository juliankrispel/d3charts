getBoundingBox = (elements) ->

    left = Infinity
    top = Infinity
    bottom = -Infinity
    right = -Infinity

    _(elements).each((element) -> 
        bbox = element.getBBox()
        console.log bbox
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
        labels = []
        size = containerSize()

        _(exchanges.exchanges).each((exchange) ->
            p = projection([exchange[2], exchange[1]])
            labels.push
                lat: p[0]
                long: p[1]
                x: p[0]
                y: p[1]
                name: exchange[0]
                value: exchange[3]
        )

        force = d3.layout.force()
            .nodes(labels)
            .links([])
            .gravity(0)
            .size([1000, 700])
            .start()

        force.on("tick", (e) ->
            #Push nodes toward their designated focus.
            k = .003 * e.alpha;
            _(labels).each((label)->
                label.x += (label.lat - label.x) * k
                label.y += (label.long - label.y) * k
                #console.log(label)
            )

            group.selectAll('circle')
                .attr('cx', (d) -> d.x)
                .attr('cy', (d) -> d.y)

            group.selectAll('text')
                .attr('x', (d) -> d.x + bubbleScale(d.value) + 4)
                .attr('y', (d) -> d.y)

        )

        group.selectAll('.label')
            .data(labels)
            .enter()
            .append('g')
            .attr('class', 'label')

        group.selectAll('.label')
            .append('circle')
            .attr('class', 'force-node')
            .attr('name', (d) -> d.name)
            .attr('r', (d) -> 
                bubbleScale(d.value))
            .attr('cx', (d) -> d.x)
            .attr('cy', (d) -> d.y)
            .style('opacity', .5)
            .style('fill', (d) -> colorScale(d.value))

        group.selectAll('.label')
            .append('text')
            .attr('class', 'market-label force-node')
            .attr('dy', '.35em')
            .style('font-size', (d) -> fontSizeScale(d.value) + 'px')
            .style('fill', (d) -> colorScale(d.value))
            .text((d) ->  d.value + '%' )
            .attr('x', (d) -> d.x)
            .attr('y', (d) -> d.y)
            .append('tspan')
            .style('font-size', (d) -> fontSizeScale(d.value) - 1 + 'px')
            .text (d) -> d.name


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

        dimensions = group[0][0].getBBox()

        s = .95 / Math.max((b[1][0] - b[0][0]) / dimensions.width + 20, (b[1][1] - b[0][1]) / dimensions.height)
        t = [(dimensions.width - s * (b[1][0] + b[0][0])) / 2, (dimensions.height - s * (b[1][1] + b[0][1])) / 2]

        group.transition().duration(750).attr("transform",
            "translate(" + projection.translate() + ")" + "scale(" + .9 / Math.max((b[1][0] - b[0][0]) / dimensions.width, (b[1][1] - b[0][1]) / dimensions.height) + ")" + "translate(" + -(b[1][0] + b[0][0]) / 2 + "," + -(b[1][1] + b[0][1]) / 2 + ")")




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


