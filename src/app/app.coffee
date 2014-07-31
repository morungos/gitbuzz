angular.module 'morungos', [
  'ui.bootstrap'
  'ui.router'
  'webapp.home'
  'webapp-templates'
]

.config Array '$stateProvider', ($stateProvider) ->
  $stateProvider
    .state 'home',
      controller: 'HomeController'
      templateUrl: '/webapp/home/home.html'
      url: '/'

.config Array '$locationProvider', ($locationProvider) ->
  $locationProvider.html5Mode(true)
  $locationProvider.hashPrefix = "!"

