
root = exports ? this

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


DotPlot = () ->
  width = 200
  height = 600
  data = []
  dots = null
  margin = {top: 20, right: 200, bottom: 0, left: 10}
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

    tracks = tracks.slice(0,15)

    play_extent = d3.extent(tracks, (d) -> d.play_count)
    xScale.domain(play_extent)
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
      .text((d) -> d.title)
    $('svg .dot').tipsy({
      gravity:'s'
      html:true
      title: () ->
        d = this.__data__
        "#{d.play_count}"
    })

  return chart

Plot = () ->
  width = 900
  height = 600
  data = []
  points = null
  margin = {top: 20, right: 20, bottom: 20, left: 20}
  xScale = d3.scale.linear().domain([0,10]).range([0,width])
  yScale = d3.scale.linear().domain([0,10]).range([0,height])
  xValue = (d) -> parseFloat(d.x)
  yValue = (d) -> parseFloat(d.y)

  chart = (selection) ->
    selection.each (rawData) ->

      data = rawData

      svg = d3.select(this).selectAll("svg").data([data])
      gEnter = svg.enter().append("svg").append("g")
      
      svg.attr("width", width + margin.left + margin.right )
      svg.attr("height", height + margin.top + margin.bottom )

      g = svg.select("g")
        .attr("transform", "translate(#{margin.left},#{margin.top})")

      points = g.append("g").attr("id", "vis_points")
      update()

  update = () ->
    points.selectAll(".point")
      .data(data).enter()
      .append("circle")
      .attr("cx", (d) -> xScale(xValue(d)))
      .attr("cy", (d) -> yScale(yValue(d)))
      .attr("r", 8)
      .attr("fill", "steelblue")

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

#root.Plot = Plot

root.plotData = (selector, data, plot) ->
  d3.select(selector)
    .datum(data)
    .call(plot)


setup_page = (data) ->
  d3.select("#title_name").html(data.name)

$ ->

  user_id = 6

  top_plot = ForceTags()
  dot_plot = DotPlot()

  display = (error, data) ->
    setup_page(data)
    plotData("#top_vis", data, top_plot)
    plotData("#dot_vis", data, dot_plot)

  queue()
    .defer(d3.json, "data/users/#{user_id}.json")
    .await(display)

