app = angular.module 'newshub'

app.service('urlService', () ->

	urlService = {}

	apiPrefix = '/api'

	urlService.timestamp = (freq) ->
		freq = freq || 3000
		return Math.floor Date.now() / freq

	urlService.list = (type, page) ->
		return "/static/list/#{type}/#{if page && page > 1 then page else 'index' }.json?t=#{urlService.timestamp()}"

	urlService.profile = (id) ->
		return "/static/profile/#{id}.json?t=#{urlService.timestamp()}"

	urlService.getPost = (id) ->
		return "/static/post/#{id}.json?t=#{urlService.timestamp()}"

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