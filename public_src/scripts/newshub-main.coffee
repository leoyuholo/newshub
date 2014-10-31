app = angular.module 'newshub', ['ngRoute', 'ngCookies']

window.callFn = (fn) ->
	fn.apply(null, Array.prototype.slice.call(arguments, 1)) if 'function' == typeof fn

app.config( ($routeProvider) ->

	$routeProvider
	.when('/', {
		controller: 'ListController',
		templateUrl: 'views/list'
	})
	.when('/login', {
		controller: 'LoginController',
		templateUrl: 'views/login'
	})
	.when('/post/:id', {
		controller: 'PostController',
		templateUrl: 'views/post'
	})
	.when('/submit', {
		controller: 'SubmitController',
		templateUrl: 'views/submit'
	})
	.when('/profile/:id', {
		controller: 'ProfileController',
		templateUrl: 'views/profile'
	})
	.otherwise({
		redirectTo: '/'
	})

	return
)

app.run( ($rootScope, $location, userService, alertService) ->
	$rootScope.$on '$routeChangeSuccess', () ->
		alertService.clear()
	user = userService.getUser()
	if user
		userService.setUser(user.id, user.name)
	$rootScope.logout = () ->
		userService.logout (err, date) ->
			alertService.success('Signed out successfully. Redirecting...', 2000, () ->
				$location.path('/')
				$location.replace()
			)
			
	userService.login 'a@b', 'a', (err) ->
		if err
			userService.signup('a@b', 'test', 'a')
)
