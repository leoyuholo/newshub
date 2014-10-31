app = angular.module 'newshub'

app.controller('SubmitController', ($scope, $location, userService, postService, alertService) ->

	if !userService.getUser()
		$location.path '/login'
		$location.replace()
		return

	$scope.urlTextToggle = "url"

	$scope.submitPost = (title, url, text) ->

		if "url" == $scope.urlTextToggle
			text = ""
		else
			url = ""

		postService.create(title, url, text, (err, data) ->
			if err
				alertService.error err.message
			else
				alertService.success 'Post submitted. Redirecting...', 0, () ->
					$location.path '/'
					$location.search 'sort', 'new'
					$location.replace()
		)
)