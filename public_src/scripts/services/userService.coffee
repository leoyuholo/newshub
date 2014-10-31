app = angular.module 'newshub'

app.service('userService', ($http, $rootScope, urlService) ->

	userService = {}

	userService.setUser = (uid, uname) ->
		localStorage.setItem('uid', uid)
		localStorage.setItem('uname', uname)
		$rootScope.user =
			id: uid
			name: uname

	userService.getUser = () ->
		uid = localStorage.getItem('uid')
		if uid
			user =
				id: uid
				name: localStorage.getItem('uname')
		
		return user

	userService.clearUser = () ->
		localStorage.removeItem('uid')
		localStorage.removeItem('uname')
		$rootScope.user = {}

	userService.login = (email, password, done) ->
		payload = 
			email: email
			password: password

		$http.post(urlService.login(), payload).success( (data) ->
			if data.success
				userService.setUser data.uid, data.uname
				callFn done, null, data
			else
				callFn done, new Error(data.msg)
		)

	userService.logout = (done) ->
		$http.get(urlService.logout()).success( (data) ->
			if data.success
				userService.clearUser()
				callFn done, null, data
			else
				callFn done, new Error(data.msg)
		)

	userService.signup = (email, username, password, done) ->
		payload = 
			email: email
			username: username
			password: password

		$http.post(urlService.signUp(), payload).success( (data) ->
			if data.success
				userService.setUser data.uid, data.uname
				callFn done, null, data
			else
				callFn done, new Error(data.msg)
		)

	userService.getProfile = (id, done) ->
		$http.get(urlService.profile(id)).success( (data) ->
			callFn done, null, data
		)

	return userService
)