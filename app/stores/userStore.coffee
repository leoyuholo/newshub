$ = require '../globals'

redisClient = $.redisClient
module.exports = userStore = {}

userHKey = 'users'
idKey = 'userid'

incrUserId = (done) ->
	redisClient.incr idKey, done

userStore.setUser = (user, done) ->
	redisClient.hset userHKey, user.email, JSON.stringify(user), (err) ->
		done err, user

userStore.findByEmail = (email, done) ->
	redisClient.hget userHKey, email, (err, json) ->
		return done err if err
		done null, JSON.parse json

userStore.createUser = (email, username, password, done) ->
	userStore.findByEmail email, (err, user) ->
		if !err && !user
			incrUserId (err, id) ->
				user =
					id: id
					email: email
					username: username
					password: password
				userStore.setUser user, done
		else if user
			done new Error('User already exist.')
