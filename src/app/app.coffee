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
    .state 'home.repository-by-commits',
      templateUrl: '/webapp/displays/repository-by-commits.html'
    .state 'home.user-by-commits',
      templateUrl: '/webapp/displays/user-by-commits.html'
    .state 'home.clock',
      templateUrl: '/webapp/displays/clock.html'
    .state 'home.most-recent-commit',
      templateUrl: '/webapp/displays/most-recent-commit.html'

.config Array '$locationProvider', ($locationProvider) ->
  $locationProvider.html5Mode(true)
  $locationProvider.hashPrefix = "!"

