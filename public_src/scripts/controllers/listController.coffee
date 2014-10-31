app = angular.module 'newshub'

app.controller('ListController', ($scope, $routeParams, $rootScope, $location, postService, alertService) ->

	page = $routeParams.page || 1
	type = $routeParams.sort || 'top'

	postService.list(type, page, (err, data) ->
		$scope.data = data
	)

	$scope.nextPage = () ->
		$location.search 'page', page + 1
		$location.replace()

	$scope.upVotePost = (post) ->
		post.votes = post.votes || []
		postService.vote(post.id, post.votes, $rootScope.user.id, (err, data) ->
			if err
				alertService.error err.message
			else
				post.vcnt = post.votes.length
				alertService.success 'Vote submitted.'
		)
)