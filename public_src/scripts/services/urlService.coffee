app = angular.module 'newshub'

app.service('urlService', () ->

	urlService = {}

	apiPrefix = '/api'

	urlService.list = (type, page) ->
		return "/static/list/#{type}/#{if page && page > 1 then page else 'index' }.json"

	urlService.profile = (id) ->
		return "/static/profile/#{id}.json"

	urlService.getPost = (id) ->
		return "/static/post/#{id}.json"

	urlService.createPost = () ->
		return "#{apiPrefix}/post/create"

	urlService.replyPost = () ->
		return "#{apiPrefix}/post/reply"

	urlService.votePost = () ->
		return "#{apiPrefix}/post/vote"

	urlService.login = () ->
		return "#{apiPrefix}/auth/login"

	urlService.signUp = () ->
		return "#{apiPrefix}/auth/signup"

	urlService.logout = () ->
		return "#{apiPrefix}/auth/logout"

	return urlService
)