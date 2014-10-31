passport = require 'passport'
passportLocal = require 'passport-local'
session = require 'express-session'
connectRedis = require 'connect-redis'

$ = require '../globals'
module.exports = authService = {}

init = (app, config, userStore) ->
	passport.serializeUser (user, done) ->
		done null, user.email

	passport.deserializeUser (email, done) ->
		userStore.findByEmail email, done

	localStrategyOptions =
		usernameField: 'email'
		passwordField: 'password'

	passport.use(
		new passportLocal.Strategy(
			localStrategyOptions, (email, password, done) ->
				userStore.findByEmail email, (err, user) ->
					return done err if err

					if !user
						return done null, false
					else if user.password != password
						return done null, false
					else
						return done null, user
		)
	)

	RedisStore = connectRedis(session)
	app.use session
		store: new RedisStore(
			host: config.redis.host
			port: config.redis.port
		)
		secret: config.sessionSecret
		cookie:
			maxAge: 2419200000
	app.use passport.initialize()
	app.use passport.session()

init($.app, $.config, $.stores.userStore)

authService.login = (req, res, next) ->
	passport.authenticate('local', (err, user, info) ->
		return next err if err

		if !user
			next new Error 'Incorrect email or password.'
		else
			req.logIn(user, (err) ->
				if err
					next new Error 'Server error.'
				else
					res.send
						success: true
						uid: user.id
						uname: user.username
			)
	)(req, res, next)

authService.signup = (req, res, next) ->
	email = req.param 'email'
	username = req.param 'username'
	password = req.param 'password'

	$.stores.userStore.createUser email, username, password, (err, user) ->
		if err || !user
			next err
		else
			authService.login req, res, next

authService.logout = (req, res, next) ->
	req.logout()
	res.send
		success: true

authService.ensureAuthenticated = (req, res, next) ->
	if req.isAuthenticated()
		next()
	else
		next new Error 'Unauthorized access.'
