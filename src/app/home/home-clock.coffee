angular
  .module 'webapp.home'

  .directive 'buzzClock', Array '$interval', ($interval) ->
    result =
      restrict: "A"
      replace: true
      scope: false
      template: '<div class="clock"></div>'
      link: (scope, iElement, iAttrs) ->

        display = jQuery(iElement)
        element = display.get()[0]

        radians = 0.0174532925
        clockRadius = 200
        margin = 50
        width = (clockRadius+margin)*2
        height = (clockRadius+margin)*2
        hourHandLength = 2*clockRadius/3
        minuteHandLength = clockRadius
        secondHandLength = clockRadius-12
        secondHandBalance = 30
        secondTickStart = clockRadius
        secondTickLength = -10
        hourTickStart = clockRadius
        hourTickLength = -18
        secondLabelRadius = clockRadius + 16
        secondLabelYOffset = 5
        hourLabelRadius = clockRadius - 40
        hourLabelYOffset = 7

        hourScale = d3.scale.linear()
          .range([0,330])
          .domain([0,11])

        minuteScale = secondScale = d3.scale.linear()
          .range([0,354])
          .domain([0,59])

        handData = [
          {
            type: 'hour',
            value: 0,
            length: -hourHandLength,
            scale: hourScale
          }, {
            type: 'minute',
            value: 0,
            length: -minuteHandLength,
            scale: minuteScale
          }, {
            type: 'second',
            value: 0,
            length: -secondHandLength,
            scale: secondScale,
            balance: secondHandBalance
          }
        ]

        drawClock = () ->
          updateData()

          svg = d3.select(element)
            .append("svg")
            .attr("width", width)
            .attr("height", height)

          face = svg.append('g')
            .attr('id','clock-face')
            .attr('transform','translate(' + (clockRadius + margin) + ',' + (clockRadius + margin) + ')')

          face.selectAll('.second-tick')
            .data(d3.range(0,60))
            .enter()
            .append('line')
            .attr('class', 'second-tick')
            .attr('x1',0)
            .attr('x2',0)
            .attr('y1',secondTickStart)
            .attr('y2',secondTickStart + secondTickLength)
            .attr('transform', (d) -> 'rotate(' + secondScale(d) + ')')

          face.selectAll('.hour-tick')
            .data(d3.range(0,12))
            .enter()
            .append('line')
            .attr('class', 'hour-tick')
            .attr('x1',0)
            .attr('x2',0)
            .attr('y1',hourTickStart)
            .attr('y2',hourTickStart + hourTickLength)
            .attr('transform', (d) -> 'rotate(' + hourScale(d) + ')')

          hands = face.append('g')
            .attr('id','clock-hands')

          face.append('g')
            .attr('id','face-overlay')
            .append('circle')
            .attr('class','hands-cover')
            .attr('x',0)
            .attr('y',0)
            .attr('r',clockRadius/20)

          hands.selectAll('line')
            .data(handData)
            .enter()
            .append('line')
            .attr('class', (d) -> d.type + '-hand')
            .attr('x1',0)
            .attr('y1', (d) -> if d.balance then d.balance else 0)
            .attr('x2',0)
            .attr('y2', (d) -> d.length)
            .attr('transform', (d) ->'rotate('+ d.scale(d.value) + ')')

        moveHands = () ->
          d3.select('#clock-hands')
            .selectAll('line')
            .data(handData)
            .transition()
            .attr('transform', (d) -> 'rotate('+ d.scale(d.value) + ')')

        updateData = () ->
          t = new Date()
          handData[0].value = (t.getHours() % 12) + t.getMinutes()/60
          handData[1].value = t.getMinutes()
          handData[2].value = t.getSeconds()

        drawClock()

        intervalFunction = () ->
          console.log "Tick"
          updateData()
          moveHands()

        $interval intervalFunction, 1000

