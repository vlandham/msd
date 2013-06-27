
root = exports ? this

# verbose helper to make circle layout easier.
# could be simplified...
# from my tutorial: http://flowingdata.com/2012/08/02/how-to-make-an-interactive-network-visualization/
RadialPlacement = () ->
  # stores the key -> location values
  values = d3.map()
  # how much to separate each location by
  increment = 20
  # how large to make the layout
  radius = 200
  # where the center of the layout should be
  center = {"x":0, "y":0}
  # what angle to start at
  start = -120
  current = start

  # Given an center point, angle, and radius length,
  # return a radial position for that angle
  radialLocation = (center, angle, radius) ->
    x = (center.x + radius * Math.cos(angle * Math.PI / 180))
    y = (center.y + radius * Math.sin(angle * Math.PI / 180))
    {"x":x,"y":y}

  # Main entry point for RadialPlacement
  # Returns location for a particular key,
  # creating a new location if necessary.
  placement = (key) ->
    value = values.get(key)
    if !values.has(key)
      value = place(key)
    value

  # Gets a new location for input key
  place = (key) ->
    value = radialLocation(center, current, radius)
    values.set(key,value)
    current += increment
    value

   # Given a set of keys, perform some 
  # magic to create a two ringed radial layout.
  # Expects radius, increment, and center to be set.
  # If there are a small number of keys, just make
  # one circle.
  setKeys = (keys) ->
    # start with an empty values
    values = d3.map()
  
    # number of keys to go in first circle
    firstCircleCount = 360 / increment

    # if we don't have enough keys, modify increment
    # so that they all fit in one circle
    if keys.length < firstCircleCount
      increment = 360 / keys.length

    # set locations for inner circle
    firstCircleKeys = keys.slice(0,firstCircleCount)
    firstCircleKeys.forEach (k) -> place(k)

    # set locations for outer circle
    secondCircleKeys = keys.slice(firstCircleCount)

    # setup outer circle
    radius = radius + radius / 1.8
    increment = 360 / secondCircleKeys.length

    secondCircleKeys.forEach (k) -> place(k)

  placement.keys = (_) ->
    if !arguments.length
      return d3.keys(values)
    setKeys(_)
    placement

  placement.center = (_) ->
    if !arguments.length
      return center
    center = _
    placement

  placement.radius = (_) ->
    if !arguments.length
      return radius
    radius = _
    placement

  placement.start = (_) ->
    if !arguments.length
      return start
    start = _
    current = start
    placement

  placement.increment = (_) ->
    if !arguments.length
      return increment
    increment = _
    placement

  return placement

# tags in a circle!
# top vis of songs and tags and how they are connected.
TagCircle = () ->
  width = 900
  height = 600
  data = []
  vis = null
  link = null
  node = null
  nodeData = null
  nodes = []
  links = []
  margin = {top: 20, right: 20, bottom: 30, left: 20}
  maxTrackRadius = 35
  rScaleTrack = d3.scale.sqrt().range([3, maxTrackRadius]).domain([1, 200])
  # rScaleTrack = d3.scale.pow().exponent(0.5).domain([1, 200]).range([3, maxTrackRadius])
  #circleRadius = d3.scale.sqrt().range([3, 12]).domain(countExtent)
  colors = d3.scale.category10()

  groupCenters = null
  tags = null
  tag = null
  tagRadius = 60

  charge = (node) -> -Math.pow(node.radius, 2.0) / 8

  force = d3.layout.force()
    .size([width, height])
    .gravity(0)
    .friction(0.9)
    .charge(charge)

  filterData = (rData) ->
    total_tags = 0
    rData.tags = rData.tags.filter (tag) ->
      
      keep = total_tags < 10
      total_tags += 1
      keep
    rData

  updateCenters = (rData) ->
    tags = []
    rData.tags.forEach (t) ->
      tags.push(t.id)

    groupCenters = RadialPlacement().center({"x":width / 2, "y":height / 2 })
      .radius(250).increment(28).keys(tags)

  tagData = (rData) ->
    nodes_map = d3.map()
    nodes = []
    rData.tags.forEach (t) ->
      tag_id = t.id
      # tag_node = {'radius':5,'id':tag_id, 'name':t.id, 'is_tag':true}
      # nodes_map.set(tag_id, tag_node)
      t.tracks.forEach (track) ->
        track_id = track.track_id
        if !nodes_map.has(track_id)
          track_node = {'radius':rScaleTrack(+track.play_count), 'id':track_id, 'title':track.title, 'tags':[tag_id], 'artist':track.artist_name}
          nodes_map.set(track_id, track_node)
        else
          track_node = nodes_map.get(track_id)
          track_node.tags.push(tag_id)
          nodes_map.set(track_id, track_node)

    nodes = nodes_map.values()
    {'nodes':nodes}

  chart = (selection) ->
    selection.each (rawData) ->
      data = filterData(rawData)
      updateCenters(data)
      nodeData = tagData(data)
      console.log(nodeData)

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      vis = g.append("g").attr("id", "vis_nodes")

      t = vis.append("g").attr("id", "vis_tags")
      tag = t.selectAll(".tag")
        .data(tags).enter()
        .append("circle")
        .attr("class", "tag")
        .attr("cx", (d) -> groupCenters(d).x)
        .attr("cy", (d) -> groupCenters(d).y)
        .attr("r", tagRadius)
        .style("fill", (d) -> colors(d))
        .style("opacity", 0.5)
      t.selectAll(".tag_title")
        .data(tags).enter()
        .append("text")
        .attr("class", "tag_title")
        .attr("x", (d) -> groupCenters(d).x)
        .attr("y", (d) -> groupCenters(d).y)
        .attr("dx", (d) -> if groupCenters(d).x > (width / 2) then tagRadius + 10 else -(tagRadius + 10))
        .attr("text-anchor", (d) -> if groupCenters(d).x > (width / 2) then "start" else "end")
        .attr "dy", (d) -> 
          if groupCenters(d).y > height - (height / 3)
            40
          else if groupCenters(d).y < (height / 3)
            -20
          else
            0

        .text((d) -> d)

      update()

  moveToTag = (alpha) ->
    k = alpha * 0.08
    (d) ->
      d.tags.forEach (tag) ->
        centerNode = groupCenters(tag)
        d.x += (centerNode.x - d.x) * k
        d.y += (centerNode.y - d.y) * k
  
  collide = (node) ->
    r = node.radius + 16
    nx1 = node.x - r
    nx2 = node.x + r
    ny1 = node.y - r
    ny2 = node.y + r
    (quad, x1, y1, x2, y2) ->
      if quad.point && (quad.point != node)
        x = node.x - quad.point.x
        y = node.y - quad.point.y
        l = Math.sqrt(x * x + y * y)
        r = node.radius + quad.point.radius
        if (l < r)
          l = (l - r) / l * .5
          node.x -= x *= l
          node.y -= y *= l
          quad.point.x += x
          quad.point.y += y
      return x1 > nx2 || x2 < nx1 || y1 > ny2 || y2 < ny1

  tick = (e) ->
    q = d3.geom.quadtree(nodes)
    nodes.forEach (n) ->
      q.visit(collide(n))
    node.each(moveToTag(e.alpha))

    node
      .attr("transform", (d) -> "translate(#{d.x},#{d.y})")

  hideTags = (d) ->
    vis.selectAll(".tag_link").remove()
    tag.style("opacity", 0.5)

  showTags = (d) ->
    vis.selectAll(".tag_link")
      .data(d.tags).enter()
      .insert("line", "#vis_tags")
      # .append("line")
      .attr("class", "tag_link")
      .attr("x1", (t) -> d.x)
      .attr("y1", (t) -> d.y)
      .attr("x2", (t) -> groupCenters(t).x)
      .attr("y2", (t) -> groupCenters(t).y)

    tag.filter((t) -> d.tags.indexOf(t) != -1)
      .style("opacity", 1.0)


  update = () ->
    force
      .nodes(nodeData.nodes, (d) -> d.id)
      .on("tick", tick)
      .start()

    node = vis.selectAll(".node")
      .data(force.nodes(), (d) -> d.id)
      # .style("fill", "steelblue")

    node.enter().append("g")
      .attr("class", "node")
      .attr("transform", (d) -> "translate(#{d.x},#{d.y})")
      .append("circle")
      # .attr("cx", (d) -> d.x)
      # .attr("cy", (d) -> d.y)
      .attr("r", (d) -> d.radius)
      .on("mouseover", showTags)
      .on("mouseout", hideTags)
      .on('click', (d) -> console.log(d))
      .call(force.drag)

    $('svg .node').tipsy({
      gravity:'w'
      html:true
      title: () ->
        d = this.__data__
        "<strong>#{d.title}</strong> <i>by</i> #{d.artist}"
    })

    node.exit().remove()

  chart.colors = (_) ->
    if !arguments.length
      return colors
    colors = _
    chart

  return chart

# original idea of network/tree of tags. hide/expand functionality
# didn't use as too many songs have too many tags
ForceTags = () ->
  width = 900
  height = 600
  data = []
  vis = null
  link = null
  node = null
  nodeData = null
  nodes = []
  links = []
  margin = {top: 20, right: 20, bottom: 20, left: 20}
  maxRadiusInner = 65
  rScaleInner = d3.scale.sqrt().range([2, maxRadiusInner]).domain([0, 1])
  rScaleTrack = d3.scale.sqrt().range([2, maxRadiusInner]).domain([1, 200])
  color = d3.scale.category10()
  #rInnerValue = (d) -> parseFloat(d.size)

  force = d3.layout.force()
    # .charge((d) -> -(d.size * 2 + 10))
    .charge (d) ->
      if d.is_tag
        -Math.pow(d.size, 2.0) / 2
      else
        -40
    # .charge(-30)
    # .linkDistance((d) -> if d.source.fixed then 60 else 50)
    # .linkStrength(1)
    .linkDistance(100)
    # .charge(-200)
    .size([width, height])


  filterData = (rData) ->
    total_tags = 0
    rData.tags = rData.tags.filter (tag) ->
      
      keep = total_tags < 10
      total_tags += 1
      keep
    rData

  linkData = (rData) ->
    nodes_map = d3.map()
    nodes = []
    links = []
    rData.tags.forEach (t) ->
      node_id = t.id
      tag_node = {'size':5,'id':node_id, 'name':t.id, 'is_tag':true}
      nodes_map.set(node_id, tag_node)
      t.tracks.forEach (track) ->
        track_id = track.track_id
        if !nodes_map.has(track_id)
          track_node = {'size':5, 'id':track_id, 'name':track.title}
          nodes_map.set(track_id, track_node)
        link = {'source':nodes_map.get(node_id), 'target':nodes_map.get(track_id)}
        links.push(link)
    nodes = nodes_map.values()
    {'nodes':nodes, 'links':links}

  transformData = (rData) ->
    node_id = 0
    nodeData = {'nodes':[], 'links':[]}
    nodeData.nodes.push({'name':'me', 'fixed':true, 'size':rScaleInner(0.01), 'x': width / 2, 'y': height / 2 - 80, 'children_count':rData.tags.length, 'id': ++node_id})

    rData.tags.forEach (t) ->
      t_node = {'size':rScaleInner(t.tag_stats.play_ratio), 'id':++node_id, 'name':t.id, 'children_count':t.tracks.length, 'is_tag':true, 'hide_children':true}
      nodeData.nodes.push(t_node)
      node_index = nodeData.nodes.length - 1
      nodeData.links.push({'source':0, 'target':node_index})
      t.tracks.forEach (track) ->
        track_node = {'size':rScaleTrack(track.play_count), 'id':++node_id, 'name':track.title, 'hidden':true}
        nodeData.nodes.push(track_node)
        nodeData.links.push({'source':node_index, 'target':nodeData.nodes.length - 1})

    nodeData

  chart = (selection) ->
    selection.each (rawData) ->
      data = filterData(rawData)
      nodeData = transformData(data)
      # nodeData = linkData(data)
      console.log(nodeData)

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      vis = g.append("g").attr("id", "vis_nodes")
      update()

  collide = (node) ->
    r = node.size + 16
    nx1 = node.x - r
    nx2 = node.x + r
    ny1 = node.y - r
    ny2 = node.y + r
    (quad, x1, y1, x2, y2) ->
      if quad.point && (quad.point != node)
        x = node.x - quad.point.x
        y = node.y - quad.point.y
        l = Math.sqrt(x * x + y * y)
        r = node.size + quad.point.size
        if (l < r)
          l = (l - r) / l * .5
          node.x -= x *= l
          node.y -= y *= l
          quad.point.x += x
          quad.point.y += y
      return x1 > nx2 || x2 < nx1 || y1 > ny2 || y2 < ny1

  click = (d) ->
    hide = if d.hide_children then false else true
    d.hide_children = hide
    nodeData.links.forEach (l) ->
      if l.source == d
        l.target.hidden = hide
    update()

  # click = (d) ->
  #   if d.hidden
  #     d.hidden = false
  #   else
  #     d.hidden = true
  #   update()

  tick = () ->
    q = d3.geom.quadtree(nodes)
    nodes.forEach (n) ->
      q.visit(collide(n))

    link
      .attr("x1", (d) -> d.source.x)
      .attr("y1", (d) -> d.source.y)
      .attr("x2", (d) -> d.target.x)
      .attr("y2", (d) -> d.target.y)

    node
      .attr("transform", (d) -> "translate(#{d.x},#{d.y})")
      # .attr("cx", (d) -> d.x)
      # .attr("cy", (d) -> d.y)

  update = () ->
    force
      .nodes(nodeData.nodes, (d) -> d.id)
      .links(nodeData.links, (d) -> d.source.id + "_" + d.target.id)
      .on("tick", tick)
      .start()

    nodes = nodeData.nodes.filter (d) -> !d.hidden
    links = nodeData.links.filter (d) -> !d.target.hidden

    force
      .nodes(nodes, (d) -> d.id)
      .links(links, (d) -> d.source.id + "_" + d.target.id)
      .on("tick", tick)
      .start()

    link = vis.selectAll("line.link")
      .data(force.links(), (d) -> d.target.id)

    link.enter().insert("line", ".node")
      .attr("class", "link")
      .attr("x1", (d) -> d.source.x)
      .attr("y1", (d) -> d.source.y)
      .attr("x2", (d) -> d.target.x)
      .attr("y2", (d) -> d.target.y)

    link.exit().remove()

    node = vis.selectAll(".node")
      .data(force.nodes(), (d) -> d.id)
      # .style("fill", "steelblue")

    node.enter().append("g")
      .attr("class", "node")
      .attr("transform", (d) -> "translate(#{d.x},#{d.y})")
      .append("circle")
      # .attr("cx", (d) -> d.x)
      # .attr("cy", (d) -> d.y)
      .attr("r", (d) -> d.size)
      .style("fill", (d) -> if d.is_tag then color(d.id) else "#777")
      .on("click", click)
      .call(force.drag)

    node.exit().remove()

  return chart

CircleCircle = () ->
  width = 400
  height = 780
  data = []
  circles = null
  colors = null

  rankRight = 300
  rankLeft = 100

  display = 'circle'
  margin = {top: 60, right: 10, bottom: 20, left: 50}
  xScale = d3.scale.linear().range([0,width])
  duration = 1000
  # yScale = d3.scale.linear().domain([0,10]).range([0,height])
  # yScale = d3.scale.ordinal().rangeRoundBands([0, height], 1)
  xValue = (d) -> parseFloat(d.play_count)
  yValue = (d) -> parseFloat(d.y)
  maxTags = 8
  yScale = d3.scale.linear().domain([0,maxTags]).range([0,height])
  maxRadiusInner = 35
  maxRadiusOuter = maxRadiusInner * 2
  rScaleInner = d3.scale.sqrt().range([2, maxRadiusInner]).domain([0, 1])
  rScaleOuter = d3.scale.sqrt().range([2, maxRadiusOuter]).domain([0, 1])
  yScaleRankAll = d3.scale.linear().range([0, height]).clamp(true)
  yScaleRank = d3.scale.linear().range([0, height]).clamp(true)

  convertData = (rData) ->
    data = []
    rData.tags.forEach (d) ->
      tag = {name:d.id, stats:d.tag_stats, all_stats:d.all_stats, diff:roundNumber(d.tag_stats.count_ratio * 100, 0)  - roundNumber(d.all_stats.avg_count_per_user_tracks * 100, 0)}
      data.push(tag)
    data = data.slice(0,maxTags)
    allRankExtent = d3.extent(data, (d) -> parseInt(d.all_stats.rank))
    rankExtent = d3.extent(data, (d) -> parseInt(d.stats.rank))
    max = Math.min(30, allRankExtent[1])
    max =allRankExtent[1]
    yScaleRankAll.domain([1, max])
    # yScaleRank.domain([1, rankExtent[1]])
    yScaleRank.domain([1, max])

    data

  chart = (selection) ->
    selection.each (rawData) ->
      data = convertData(rawData)

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      circles = g.append("g").attr("id", "vis_circles")
      updateCircles()

  updateRanks = () ->
    c = circles.selectAll('.out_circle')
    c.transition().duration(duration)
      .attr('cx', rankRight)
      .attr('cy', (d) -> yScaleRankAll(d.all_stats.rank))
      .attr('r', 8)

    cc = circles.selectAll('.in_circle')
    cc.transition().duration(duration)
      .attr("cx", rankLeft)
      .attr('cy', (d) -> yScaleRank(d.stats.rank))
      .attr('r', 8)

    name = circles.selectAll(".name")
    name.transition().duration(duration)
      .attr("x", rankLeft - 20)
      .attr("y", (d) -> yScaleRank(d.stats.rank))
      .attr("dy", 5)

    diffs = circles.selectAll(".diff")
    diffs.transition().duration(40)
      .style("opacity", 0)

    links = circles.selectAll('.link')
      .data(data)
    links.enter().insert('line', '.out_circle')
      .attr('class', 'link')
      .attr('opacity', 0)
      .attr('x1', (d) -> rankLeft)
      .attr('y1', (d) ->  yScaleRank(d.stats.rank))
      .attr('x2', (d) -> rankRight)
      .attr('y2', (d) -> yScaleRankAll(d.all_stats.rank))

    links.transition().duration(duration / 2).delay(duration)
      .attr("opacity", 1)

    rankTitles = circles.selectAll('.rank_title')
      .data(['You', 'Everyone'])

    rankTitles.enter().append('text')
      .attr('class', 'rank_title')
      .attr('opacity', 0)
      .attr('text-anchor', 'middle')
      .attr('x', (d,i) -> if i == 0 then rankLeft else rankRight)
      .attr('y', 0)
      .attr('dy', -24)
      .text((d) -> d)
  
    rankTitles.transition().duration(duration / 2).delay(duration)
      .attr('opacity', 1)


  updateCircles = () ->
    links = circles.selectAll('.link')
      .transition().duration(40)
      .attr('opacity', 0)

    rankTitles = circles.selectAll('.rank_title')
      .transition().duration(40)
      .attr('opacity', 0)

    c = circles.selectAll('.out_circle')
      .data(data)
    c.enter()
      .append('circle')
      .attr('class', 'out_circle')
      .attr("fill", (d) -> colors(d.name))
      .attr("opacity", 0.6)

    c.transition().duration(duration)
      .attr('cx', width / 2)
      .attr('cy', (d,i) -> yScale(i))
      .attr('r', (d) -> rScaleOuter(d.all_stats.avg_count_per_user_tracks))
      .attr("fill", (d) -> colors(d.name))
      .attr("opacity", 0.6)

    $('#vis_circles .out_circle').tipsy({
      gravity:'w'
      html:true
      title: () ->
        d = this.__data__
        if display == 'circle'
          "<strong>#{toPercentage(d.all_stats.avg_count_per_user_tracks)}</strong> of all user's tracks have #{d.name}"
        else
          "#{d.name} ranks <strong>#{(d.all_stats.rank)}</strong> for all users"
    })

    cc =circles.selectAll('.in_circle')
      .data(data)
    cc.enter()
      .append('circle')
      .attr('class', 'in_circle')
      .attr("fill", (d) -> colors(d.name))

    cc.transition().duration(duration)
      .attr('cx', width / 2)
      .attr('cy', (d,i) -> yScale(i))
      .attr('r', (d) -> rScaleInner(d.stats.count_ratio))

    $('#vis_circles .in_circle').tipsy({
      gravity:'w'
      html:true
      title: () ->
        d = this.__data__
        if display == 'circle'
          "<strong>#{toPercentage(d.stats.count_ratio)}</strong> of <strong>your</strong> tracks have #{d.name}"
        else
          "#{d.name} ranks <strong>#{(d.stats.rank)}</strong> for you"
    })

    name = circles.selectAll(".name")
      .data(data)
    name.enter()
      .append("text")
      .attr("class", "name")
      .attr("text-anchor", "end")
      .text((d) -> d.name)

    name.transition().duration(duration)
      .attr("dy", 0)
      .attr("opacity", 1.0)
      .attr("x", width / 2 - 80)
      .attr("y", (d,i) -> yScale(i))

    diffs = circles.selectAll(".diff")
      .data(data)
    diffs.enter()
      .append("text")
      .attr("class", "diff")
      .attr("x", width / 2 - 80)
      .attr("text-anchor", "end")
      .attr("y", (d,i) -> yScale(i))
      .attr("dy", 20)
      .style("fill", (d) -> colors(d.name))
      .text (d) ->
        if d.diff > 0
          "+#{d.diff}%"
        else
          "#{d.diff}%"

    diffs.transition().duration(duration / 2).delay(duration)
      .style("opacity", (d) -> if d.diff > 0 then 1.0 else 0.5)

  chart.colors = (_) ->
    if !arguments.length
      return colors
    colors = _
    chart

  chart.toggle = (newDisplay) ->
    # display = if display == 'circle' then 'rank' else 'circle'
    display = newDisplay
    if display == 'rank'
      updateRanks()
    else
      updateCircles()

  return chart

DotPlot = () ->
  width = 200
  height = 800
  data = []
  dots = null
  margin = {top: 20, right: 250, bottom: 0, left: 10}
  xScale = d3.scale.linear().range([0,width])
  # yScale = d3.scale.linear().domain([0,10]).range([0,height])
  yScale = d3.scale.linear().domain([0,10]).range([0,height])
  # yScale = d3.scale.ordinal().rangeRoundBands([0, height], 1)
  xValue = (d) -> parseFloat(d.play_count)
  yValue = (d) -> parseFloat(d.y)

  convertData = (rawData) ->
    track_map = d3.map()
    rawData.tags.forEach (tag) ->
      tag.tracks.forEach (track) ->
        track_id = track.track_id
        if !track_map.has(track_id)
          track_map.set(track_id, track)
    tracks = track_map.values()
    tracks.sort (a,b) ->
      b.play_count - a.play_count

    tracks = tracks.slice(0,20)

    play_extent = d3.extent(tracks, (d) -> d.play_count)
    xScale.domain([0, play_extent[1]])
    yScale.domain([0,tracks.length])

    tracks

  chart = (selection) ->
    selection.each (rawData) ->
      data = convertData(rawData)

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      dots = g.append("g").attr("id", "vis_dots")
      dots.append("line")
        .attr("class", "baseline")
        .attr("x1", 0)
        .attr("y1", 0)
        .attr("x2", 0)
        .attr("y2", height - 30)

      update()

  update = () ->

    dots.selectAll(".connector")
      .data(data).enter()
      .append("line")
      .attr("class", "connector")
      .attr("x1", 0)
      .attr("y1", (d,i) -> yScale(i))
      .attr("x2", (d) -> xScale(xValue(d)))
      .attr("y2", (d,i) -> yScale(i))

    dots.selectAll(".dot")
      .data(data).enter()
      .append("circle")
      .attr("class", "dot")
      .attr("cx", (d) -> xScale(xValue(d)))
      .attr("cy", (d,i) -> yScale(i))
      .attr("r", 8)

    dots.selectAll(".artist")
      .data(data).enter()
      .append("text")
      .attr("class", "artist")
      .attr("x", (d) -> xScale(xValue(d)))
      .attr("y", (d,i) -> yScale(i))
      .attr("dx", 10)
      .attr("dy", 4)
      .text((d) -> truncate(d.title, 30))
    $('svg .dot').tipsy({
      gravity:'s'
      html:true
      title: () ->
        d = this.__data__
        "<strong>#{d.play_count}</strong> listens"
    })

  chart.height = (_) ->
    if !arguments.length
      return height
    height = _
    chart

  return chart


root.plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)


root.all = {}

setupPage = (data) ->
  d3.select("#title_name").html(data.name)
  d3.select("#track_count").html(addCommas(data.total_tracks))
  d3.select("#tag_count").html(addCommas(data.total_tags))

resetPage = () ->
  d3.selectAll('.btn-group .btn')
    .classed('active', (d,i) -> if i == 0 then true else false)


openSearch = (e) ->
  $('#search_user').show('slide').select()
  $('#change_nav_link').hide()
  d3.event.preventDefault()

hideSearch = () ->
  $('#search_user').hide()
  $('#change_nav_link').show()

changeUser = (user) ->
  console.log(user)
  hideSearch()
  id = root.all.get(user)
  if id
    location.replace("#" + encodeURIComponent(id))
  # d3.event.preventDefault()
  return user

setupSearch = (all) ->
  root.all = d3.map()
  all.forEach (a) ->
    root.all.set(a.name, a.index)

  users = root.all.keys()
  console.log(users)
  $('#search_user').typeahead({source:users, updater:changeUser})

$ ->

  d3.select("#change_nav_link")
    .on("click", openSearch)

  user_id = decodeURIComponent(location.hash.substring(1)).trim()
  if !user_id
    user_id = 4

  top_plot = TagCircle()
  dot_plot = DotPlot()
  circle_plot = CircleCircle()

  display = (error, all, data) ->
    setupPage(data)
    setupSearch(all)
    plotData("#top_vis", data, top_plot)
    colors = top_plot.colors()
    plotData("#dot_vis", data, dot_plot)
    circle_plot.colors(colors)
    plotData("#circle_vis", data, circle_plot)

  queue()
    .defer(d3.csv, "data/users/all.csv")
    .defer(d3.json, "data/users/#{user_id}.json")
    .await(display)

  updateActive = (new_id) ->
    user_id = new_id
    d3.selectAll('svg').remove()
    top_plot = TagCircle()
    circle_plot = CircleCircle()
    resetPage()
    queue()
      .defer(d3.csv, "data/users/all.csv")
      .defer(d3.json, "data/users/#{user_id}.json")
      .await(display)

  hashchange = () ->
    id = decodeURIComponent(location.hash.substring(1)).trim()
    updateActive(id)

  d3.select(window)
    .on("hashchange", hashchange)

  d3.select("#circle_vis_toggle")
    .on "click", () ->
      circle_plot.toggle()
      d3.event.preventDefault()

  d3.select("#percent_toggle")
    .on "click", () ->
      circle_plot.toggle('circle')
      d3.event.preventDefault()

  d3.select("#rank_toggle")
    .on "click", () ->
      circle_plot.toggle('rank')
      d3.event.preventDefault()
