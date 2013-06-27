
root = exports ? this

Plot = () ->
  width = 700
  height = 800
  data = []
  points = null
  margin = {top: 50, right: 20, bottom: 40, left: 120}
  xScale = d3.scale.linear().domain([0,10]).range([0,width])
  yScale = d3.scale.linear().domain([0,10]).range([0,height])
  xValue = (d) -> parseFloat(d.plays)
  yValue = (d) -> parseFloat(d.users)

  parseData = (rData) ->
    playsExtent = d3.extent(rData, (d) -> xValue(d))
    xScale.domain([playsExtent[0] - 6000, playsExtent[1] + 5000])
    usersExtent = d3.extent(rData, (d) -> yValue(d))
    yScale.domain([usersExtent[0] - 1000, usersExtent[1]])

    rData

  chart = (selection) ->
    selection.each (rawData) ->

      data = parseData(rawData)

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      points = g.append("g").attr("id", "vis_points")
      update()

  update = () ->
    points.append("text")
      .attr('class', 'x title')
      .attr('x', 20)
      .attr('y', -20)
      .text("Number of times a song is played")

    points.append("text")
      .attr('class', 'y title')
      # .attr('x', 0)
      # .attr('y', 40)
      .attr("transform", "rotate(-90)translate(-260,-90)")
      .text("Number of people who have heard the song")

    points.append("line")
      .attr("class", "x axis")
      .attr("x1", 0)
      .attr("x2", 0)
      .attr("y1", 0)
      .attr("y2", height + 50)

    intervals = [30000, 45000, 60000, 75000, 90000]
    points.selectAll('.interval')
      .data(intervals)
      .enter().append("line")
      .attr('class', 'interval')
      .attr('x1', -10)
      .attr('y1', (d) -> yScale(d))
      # .attr('y1', 10)
      .attr('x2', width)
      .attr('y2', (d) -> yScale(d))

    points.selectAll('.interval_text')
      .data(intervals)
      .enter().append("text")
      .attr('class', 'interval_text')
      .attr('x', -20)
      .attr("dy", 5)
      .attr('y', (d) -> yScale(d))
      .attr("text-anchor", "end")
      .text((d) -> addCommas(d))

    points.selectAll(".point")
      .data(data).enter()
      .append("circle")
      .attr("class", "point")
      .attr("cx", (d) -> xScale(xValue(d)))
      .attr("cy", (d) -> yScale(yValue(d)))
      .attr("r", (d) -> if d.leader then 8 else 5)
      .attr("fill", (d) -> if d.leader then "#8F2C1B" else "#777")

    $('svg .point').tipsy({
      gravity:'w'
      html:true
      title: () ->
        d = this.__data__
        "<strong>#{d.meta.title}</strong> <i>by</i> #{d.meta.artist_name}"
    })

  chart.height = (_) ->
    if !arguments.length
      return height
    height = _
    chart

  chart.width = (_) ->
    if !arguments.length
      return width
    width = _
    chart

  chart.margin = (_) ->
    if !arguments.length
      return margin
    margin = _
    chart

  chart.x = (_) ->
    if !arguments.length
      return xValue
    xValue = _
    chart

  chart.y = (_) ->
    if !arguments.length
      return yValue
    yValue = _
    chart

  return chart

root.Plot = Plot

root.plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)


$ ->

  plot = Plot()
  display = (error, data) ->
    plotData("#vis", data, plot)

  queue()
    .defer(d3.json, "data/top_songs_with_meta.json")
    .await(display)

