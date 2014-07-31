angular
  .module 'webapp.home'

  .directive 'buzzRepositoryCommitsChart', () ->
    result =
      restrict: "A"
      replace: true
      transclude: true
      scope: false
      template: '<div class="diagram"></div>'
      link: (scope, iElement, iAttrs) ->
        scope.getData 'commitsByRepository', {}, (err, result) ->

          if ! err?
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

            line1 = (text) ->
              text.replace /(\/[^\/]+)$/, '/'
            line2 = (text) ->
              text.replace /^([^\/]+\/)/, ''

            classes = (nodes) ->
              result =
                children: ({name: n.name, value: n.score} for n in nodes)

            nodes = svg.selectAll(".bubble")
              .data(bubble.nodes(classes(result.data)).filter (d) -> !d.children)
              .enter()
              .append("g")
              .attr("class", "bubble")
              .attr("transform", (d) -> "translate(#{d.x},#{d.y})")

            nodes.append("circle")
              .attr("r", (d) -> d.r)
              .style("fill", (d) -> color(d.name))

            text = nodes.append("text")
              .style("font-size", (d) -> d.r / 4)

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
