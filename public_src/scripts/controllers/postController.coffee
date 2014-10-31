app = angular.module 'newshub'

app.controller('PostController', ($scope, $routeParams, $rootScope, postService, alertService) ->

	getPost = (done) ->
		postService.getPost($routeParams.id, (err, data) ->
			replies = []
			replies.push v for k, v of data.children
			data.children = replies.sort (a, b) ->
				(a.vcnt || 0) < (b.vcnt || 0)
			$scope.post = data
			callFn done, err, data
		)

	getPost()

	$scope.submitReply = (rootId, parentId, postTitle, replyText) ->
		postTitle = 'RE:' + postTitle if 'RE:' != postTitle.substr(0, 3)
		postService.reply(rootId, parentId, postTitle, replyText, (err, data) ->
			if err
				alertService.error err.message
			else
				alertService.success 'Reply submitted. Refreshing...', 0, () ->
					$scope.replyText = ''
					getPost()
		)

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