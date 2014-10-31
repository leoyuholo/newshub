app = angular.module 'newshub'

app.controller('ProfileController', ($scope, $routeParams, userService) ->

	getProfile = (done) ->
		userService.getProfile($routeParams.id, (err, data) ->
			$scope.profile = data
		)

	getProfile()

)