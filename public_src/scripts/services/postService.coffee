app = angular.module 'newshub'

app.service('postService', ($http, urlService) ->

	postService = {}

	postService.create = (title, url, text, done) ->
		payload =
			title: title
			url: url
			text: text

		$http.post(urlService.createPost(), payload).success( (data) ->
			if data.success
				callFn done, null, data
			else
				callFn done, new Error(data.msg)
		)

	postService.reply = (rootId, parentId, title, text, done) ->
		payload =
			rootId: rootId
			parentId: parentId
			title: title
			text: text

		$http.post(urlService.replyPost(), payload).success( (data) ->
			if data.success
				callFn done, null, data
			else
				callFn done, new Error(data.msg)
		)

	postService.vote = (postId, votes, userId, done) ->
		userId = '' + userId
		if -1 != votes.indexOf(userId)
			return callFn done, new Error('Already voted.')
		else
			votes.push userId

		payload =
			postId: postId

		$http.post(urlService.votePost(), payload).success( (data) ->
			if data.success
				callFn done, null, data
			else
				callFn done, new Error(data.msg)
		)

	postService.list = (type, page, done) ->
		$http.get(urlService.list(type, page)).success( (data) ->
			callFn done, null, data
		)

	postService.getPost = (id, done) ->
		$http.get(urlService.getPost(id)).success( (data) ->
			callFn done, null, data
		)

	return postService
)