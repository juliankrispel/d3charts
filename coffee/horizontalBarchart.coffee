#Config

div = d3.select("#horizontalbarchart");

d3.json "json/exchanges.normal.json", (error, data) ->
    barWidth = 100 / data.exchanges.length

    div.selectAll('div')
        .data(data.exchanges)
        .enter()
        .append('div')
        .style('width', barWidth + '%')
        .attr('class', 'barchart__bar')
        .style('height', (d) ->
            barScale(d[3]) + 'px'
        )
        .style('margin-top', (d) ->
            200 - barScale(d[3]) + 'px'
        )
        .style('background', (d) ->
            colorScale(d[3])
        )
        .append('span')
        .attr('class', 'barchart__bar__caption')
        .text((d) -> d[0])

    div.selectAll('.barchart__bar__percent')
        


