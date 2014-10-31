app = angular.module 'newshub'

app.service('urlService', () ->

	urlService = {}

	urlService.list = (type, page) ->
		return "/static/list/#{type}/#{if page && page > 1 then page else 'index' }.json"

	urlService.profile = (id) ->
		return "/static/profile/#{id}.json"

	urlService.getPost = (id) ->
		return "/static/post/#{id}.json"

	urlService.createPost = () ->
		return '/api/post/create'

	urlService.replyPost = () ->
		return '/api/post/reply'

	urlService.votePost = () ->
		return '/api/post/vote'

	urlService.login = () ->
		return '/api/auth/login'

	urlService.signUp = () ->
		return '/api/auth/signup'

	urlService.logout = () ->
		return '/api/auth/logout'

	return urlService
)