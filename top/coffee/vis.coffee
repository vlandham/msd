
root = exports ? this

DiffPlot = () ->
  width = 700
  height = 800
  data = []
  matches = []
  followers = []
  points = null
  margin = {top: 50, right: 20, bottom: 40, left: 220}
  xScale = d3.scale.linear().domain([0,10]).range([0,width])
  yScale = d3.scale.linear().domain([0,10]).range([0,height])
  xValue = (d) -> parseFloat(d.plays)
  yValue = (d) -> parseFloat(d.users)


  parseData = (rData) ->
    playsExtent = d3.extent(rData, (d) -> xValue(d))
    xScale.domain([playsExtent[0] - 6000, playsExtent[1] + 5000])
    usersExtent = d3.extent(rData, (d) -> yValue(d))
    yScale.domain([usersExtent[0] - 1000, usersExtent[1]])

    leaders = rData.filter((d) -> d.leader).sort((a,b) -> b.users - a.users)
    followers = rData.filter((d) -> !d.leader).sort((a,b) -> b.users - a.users)

    # grab the closest follower for each leader and remove it from followers
    matches = []
    l1 = leaders.shift()
    f1 = followers.shift()
    avg_dist = roundNumber((l1.users + f1.users) / 2, 0)
    matches.push({leader:l1, follower:f1, users:avg_dist})
    leaders.forEach (l) ->
      minDistance = 9999999999999
      minIndex = -1
      followers.forEach (f,i) ->
        dist = Math.abs(l.users - f.users)
        if dist < minDistance
          minDistance = dist
          minIndex = i
      if minIndex >= 0
        follower = followers.splice(minIndex,1)[0]
        avg_dist = roundNumber((l.users + follower.users) / 2, 0)
        matches.push({leader:l, follower:follower, users:avg_dist})
      else
        console.log('error: cant find follower: ' + l)
        console.log(l)


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

    points.append("line")
      .attr("class", "arrow")
      .attr('x1', 220)
      .attr('y1', 0)
      .attr('x2', 295)
      .attr('y2', 0)

    points.append("text")
      .attr('class', 'y title')
      .attr('x', -180)
      .attr('y', 0)
      # .attr("transform", "rotate(-90)translate(-260,-90)")
      .text("Number of people who ") #have heard the song")
    points.append("text")
      .attr('class', 'y title')
      .attr('x', -180)
      .attr('y', 20)
      .text("have heard") #have heard the song")
    points.append("text")
      .attr('class', 'y title')
      .attr('x', -180)
      .attr('y', 40)
      .text("the song") #have heard the song")

    points.append("line")
      .attr("class", "arrow")
      .attr('x1', -110)
      .attr('y1', 35)
      .attr('x2', -110)
      .attr('y2', 100)

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
      .data(followers).enter()
      .append("circle")
      .attr("class", "point")
      .attr("cx", (d) -> xScale(xValue(d)))
      .attr("cy", (d) -> yScale(yValue(d)))
      .attr("r", (d) -> if d.leader then 8 else 5)
      .attr("fill", (d) -> if d.leader then "#8F2C1B" else "#777")

    m = points.selectAll(".match")
      .data(matches).enter()
      .append("g")
      .attr("class", "match_set")

    # m.append("line")
      # .attr("class", "match")
      # .attr("x1", (d) -> xScale(xValue(d.leader)))
      # .attr("y1", (d) -> yScale(yValue(d.leader)))
      # .attr("x2", (d) -> xScale(xValue(d.follower)))
      # .attr("y2", (d) -> yScale(yValue(d.follower)))
    m.append("path")
      .attr("class", "match")
      .attr "d", (d) -> 
        x1 = xScale(xValue(d.leader))
        y1 = yScale(yValue(d.leader))
        x2 = xScale(xValue(d.follower))
        y2 = yScale(yValue(d.follower))
        "M #{x1} #{y1} L #{x2} #{y1} L #{x2} #{y2}"
    m.append("circle").datum((d) -> d.follower)
      .attr("class", "point follower")
      .attr("cx", (d) -> xScale(xValue(d)))
      .attr("cy", (d) -> yScale(yValue(d)))
      .attr("r", (d) -> 5)
      .attr("fill", (d) -> "#777")
    m.append("circle").datum((d) -> d.leader)
      .attr("class", 'point leader')
      .attr("cx", (d) -> xScale(xValue(d)))
      .attr("cy", (d) -> yScale(yValue(d)))
      .attr("r", (d) -> 8)
      .attr("fill", (d) -> "#8F2C1B")

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

ScatterPlot = () ->
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


root.plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)


$ ->

  plot = DiffPlot()
  display = (error, data) ->
    plotData("#vis", data, plot)

  queue()
    .defer(d3.json, "data/top_songs_with_meta.json")
    .await(display)

