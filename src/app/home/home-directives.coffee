angular
  .module 'webapp.home'

  .directive 'buzzAwardWinner', () ->
    result =
      replace: true
      scope: false
      template: '<div class="awards">' +
                '<h2><span class="languageKey"></span> award: &#8220;<span class="languageDescription"></span>&#8221;</h3>' +
                '<div class="awards-winners"></div>' +
                '</div>'
      link: (scope, iElement, iAttrs) ->
        languages =
          "Java": "Classpath Champions",
          "Perl": "Sigil Ninjas",
          "JavaScript": "Prototype Virtuosi"
        languageKeys = Object.keys languages
        selectedLanguage = languageKeys[Math.floor(Math.random() * languageKeys.length)]
        iElement.find(".languageKey").append(selectedLanguage)
        iElement.find(".languageDescription").append(languages[selectedLanguage])

        labels = [
          "award-gold",
          "award-silver",
          "award-bronze"
        ]

        scope.getData 'awardWinner', {language: selectedLanguage}, (err, result) ->
          if ! err?

            for entry, i in result.data
              icon = "<div class='award-icon #{labels[i]}'><span class='glyphicon glyphicon-star'></span></div>"
              name = "<div class='award-name'>#{entry._id}</div>"
              explanation = "<div class='award-justification'>#{entry.lines} lines in #{entry.commits} commits</div>"
              element = angular.element "<div class='award'>#{icon} #{name} #{explanation}</div>"
              iElement.find(".awards-winners").append(element)

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


  .directive 'buzzTeamsChart', () ->
    result =
      restrict: "A"
      replace: true
      transclude: true
      scope: false
      template: '<div class="diagram"></div>'
      link: (scope, iElement, iAttrs) ->
        scope.getData 'teams', {}, (err, result) ->

          if ! err?
            display = jQuery(iElement)
            element = display.get()[0]

            chartWidth = 640
            chartHeight = 650
            barHeight = 50
            textMargin = 80

            color = d3.scale.category20c()

            x = d3.scale.linear()
              .range([0, chartWidth - textMargin])

            x.domain([0, d3.max(result.data, (d) -> d.commits)])

            svg = d3.select(element)
              .append("svg")
              .attr("width", chartWidth)
              .attr("height", chartHeight)
              .attr("class", "bar")

            svg.attr("height", barHeight * result.data.length)

            bar = svg.selectAll("g")
              .data(result.data)
              .enter()
              .append("g")
              .attr("transform", (d, i) -> "translate(0," + i * barHeight + ")")

            bar.append("rect")
              .attr("width", 0)
              .attr("height", barHeight - 1)
              .style("fill", (d, i) -> color(i))
              .transition().duration(2000).attr("width", (d) -> x(d.commits))

            bar.append("text")
              .attr("x", -3)
              .attr("y", barHeight / 2)
              .attr("dy", ".35em")
              .attr("dx", "0.5em")
              .text((d) -> d._id)
              .transition().duration(2000).attr("x", (d) -> x(d.commits) - 3)


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

