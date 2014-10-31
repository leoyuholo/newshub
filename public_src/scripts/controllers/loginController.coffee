app = angular.module 'newshub'

app.controller('LoginController', ($scope, $location, userService, alertService) ->

	$scope.submitLogin = (email, password) ->
		alertService.clear()
		userService.login(email, password, (err, user) ->
			if err
				alertService.error err.message, -1
			else
				alertService.success 'Logged in successfully. Redirecting...', 2000, () ->
					$location.path('/')
					$location.replace()
		)

	$scope.submitSignUp = (email, username, password) ->
		alertService.clear()
		userService.signup(email, username, password, (err, data) ->
			if err
				alertService.error err.message, -1
			else
				alertService.success 'Signed up successfully. Redirecting...', 2000, () ->
					$location.path('/')
					$location.replace()
		)
)