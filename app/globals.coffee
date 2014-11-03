path = require 'path'
events = require 'events'

express = require 'express'
bodyParser = require 'body-parser'
cookieParser = require 'cookie-parser'
redis = require 'redis'

config = require '../config.json'
include = require './include'

module.exports = $ = {}

# default config
$.config = config
config.host = config.host || 'localhost'
config.port = config.port || 8000
config.sessionSecret = config.sessionSecret || 'newshub secret'

# dir
$.rootdir = path.join __dirname, '../'
$.publicdir = path.join $.rootdir, 'public/'

# db connections
$.redis = redis
$.redisClient = redis.createClient config.redis.port, config.redis.host

# configurate express app
$.express = express
app = $.app = express()
app.use cookieParser()
app.use bodyParser.json()
app.use bodyParser.urlencoded {extended:true}

$.emitter = new events.EventEmitter()

# initialzation sequence is important
$.stores = include path.join(__dirname, './stores'), true
$.services = include path.join(__dirname, './services'), true
$.controllers = include path.join(__dirname, './controllers'), true
$.tasks = include path.join(__dirname, './tasks'), true
$.listeners = include path.join(__dirname, './listeners'), true

$.computeScore = require './computeScore'

# route
api = express.Router()
api.use '/auth', $.controllers.authController
api.use '/post', $.services.authService.ensureAuthenticated, $.controllers.postController
api.use (err, req, res, next) ->
	if err
		res.send
			success: false
			msg: err.message

app.use express.static $.publicdir
app.use '/api', api
