angular
  .module 'webapp.home'
  .controller 'HomeController', Array '$scope', '$http', ($scope, $http) ->
    'use strict'

    $scope.getData = (analysis, options, callback) ->
      $http {method: 'GET', url: "/api/#{analysis}"}
        .success (data, status, headers, config) ->
          callback null, data
        .error (data, status, headers, config) ->
          callback status, data
