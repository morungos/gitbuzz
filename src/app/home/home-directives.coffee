angular
  .module 'webapp.home'

  .directive 'buzzMostRecentCommit', () ->
    result =
      replace: true
      scope: false
      template: '<div class="commit">' +
                '  <img class="avatar" src=""></img>' +
                '  <div class="repository"></div>' +
                '  <div class="message"></div>' +
                '  <div class="strapline">' +
                '    <div class="user"></div>' +
                '    <div class="date"></div>' +
                '  </div>' +
                '</div>'
      link: (scope, iElement, iAttrs) ->
        scope.getData 'mostRecentCommit', {}, (err, result) ->
          if ! err?
            message = result.data.payload.commits.message
            user = result.data.actor.login
            gravatar = result.data.actor.avatar_url
            repository = result.data.repo.name
            date = new Date(result.data.payload.commits.buzzData.date)
            iElement.find(".avatar").attr('src', gravatar)
            iElement.find(".repository").append(repository)
            iElement.find(".message").append(message)
            iElement.find(".user").append(user)
            iElement.find(".date").append(date.toDateString() + ", " + date.toLocaleTimeString())

  .directive 'buzzRepositoryCommitsChart', () ->
    result =
      restrict: "A"
      replace: true
      scope: false
      template: '<div class="diagram"></div>'
      link: (scope, iElement, iAttrs) ->
        scope.getData 'commitsByRepository', {}, (err, result) ->

          if ! err?
            line1 = (text) ->
              text.replace /(\/[^\/]+)$/, '/'
            line2 = (text) ->
              text.replace /^([^\/]+\/)/, ''

            classes = (nodes) ->
              result =
                children: ({name: n.name, value: n.score} for n in nodes)

            bubbleChart iElement, classes(result.data), (text) ->
              text.append("tspan")
                .attr("dy", "-.5em")
                .attr("x", "0")
                .style("text-anchor", "middle")
                .text((d) -> line1(d.name))
              text.append("tspan")
                .attr("dy", "1.2em")
                .attr("x", "0")
                .style("text-anchor", "middle")
                .text((d) -> line2(d.name))


  .directive 'buzzUserCommitsChart', () ->
    result =
      restrict: "A"
      replace: true
      transclude: true
      scope: false
      template: '<div class="diagram"></div>'
      link: (scope, iElement, iAttrs) ->
        scope.getData 'commitsByUser', {}, (err, result) ->

          if ! err?
            classes = (nodes) ->
              result =
                children: ({name: n.name, value: n.score} for n in nodes)

            bubbleChart iElement, classes(result.data), (text) ->
              text.append("tspan")
                .attr("dy", "0.5em")
                .attr("x", "0")
                .style("text-anchor", "middle")
                .text((d) -> d.name)


bubbleChart = (iElement, nodes, labeller) ->
  display = jQuery(iElement)
  element = display.get()[0]

  chartWidth = 840
  chartHeight = 650
  color = d3.scale.category20c()

  svg = d3.select(element)
    .append("svg")
    .attr("width", chartWidth)
    .attr("height", chartHeight)
    .attr("class", "bubble")

  bubble = d3.layout.pack()
    .sort(null)
    .size([chartWidth, chartHeight])
    .padding(1.5)

  nodes = svg.selectAll(".bubble")
    .data(bubble.nodes(nodes).filter (d) -> !d.children)
    .enter()
    .append("g")
    .attr("class", "bubble")
    .attr("transform", (d) -> "translate(#{d.x},#{d.y})")

  nodes.append("circle")
    .attr("r", 0)
    .style("fill", (d) -> color(d.name))
    .transition().duration(500).attr("r", (d) -> d.r)

  text = nodes.append("text")
    .style("font-size", (d) -> d.r / 4)

  labeller(text)

