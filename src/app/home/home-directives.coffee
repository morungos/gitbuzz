angular
  .module 'webapp.home'

  .directive 'buzzCommitsChart', () ->
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

            nodes.append("text")
              .attr("dy", ".3em")
              .style("text-anchor", "middle")
              .style("font-size", (d) -> d.r / 4)
              .text((d) -> d.name)
