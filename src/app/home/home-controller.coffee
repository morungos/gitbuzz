angular
  .module 'webapp.home'
  .controller 'HomeController', Array '$scope', '$http', '$state', '$interval', ($scope, $http, $state, $interval) ->
    'use strict'

    stateTable = [
      'home.clock'
      'home.award-winner',
      'home.most-recent-commit',
      'home.user-by-commits',
      'home.repository-by-commits'
    ]

    currentStateIndex = 0

    changeState = () ->
      currentStateIndex = (currentStateIndex + 1) % stateTable.length
      console.log "changeState", currentStateIndex
      $state.transitionTo(stateTable[currentStateIndex])

    $interval(changeState, 30000)

    $state.transitionTo(stateTable[currentStateIndex])

    $scope.getData = (analysis, options, callback) ->
      $http {method: 'GET', url: "/api/#{analysis}", params: options}
        .success (data, status, headers, config) ->
          callback null, data
        .error (data, status, headers, config) ->
          callback status, data
