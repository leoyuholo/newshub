path = require 'path'
events = require 'events'

express = require 'express'
bodyParser = require 'body-parser'
cookieParser = require 'cookie-parser'
redis = require 'redis'

include = require './include'

module.exports = $ = {}

# configurate express app
$.express = express
app = $.app = express()
app.use cookieParser()
app.use bodyParser.json()
app.use bodyParser.urlencoded {extended:true}

# default config
if 'development' == app.settings.env
	$.config = config = require '../config.json'
else
	$.config = config = require '../config_prod.json'
config.origin = config.origin || 'localhost'
config.port = config.port || 8000
config.sessionSecret = config.sessionSecret || 'newshub secret'

# dir
$.rootdir = path.join __dirname, '../'
$.publicdir = path.join $.rootdir, 'public/'

# db connections
$.redis = redis
$.redisClient = redis.createClient config.redis.port, config.redis.host

# events
$.emitter = new events.EventEmitter()

# initialzation sequence is important
$.stores = include path.join(__dirname, './stores'), true
$.services = include path.join(__dirname, './services'), true
$.controllers = include path.join(__dirname, './controllers'), true
$.tasks = include path.join(__dirname, './tasks'), true
$.listeners = include path.join(__dirname, './listeners'), true

# score function
$.computeScore = require './computeScore'

# route
api = express.Router()
api.use '/health', (req, res, next) ->
	res.send 'OK'
api.use '/auth', $.controllers.authController
api.use '/post', $.services.authService.ensureAuthenticated, $.controllers.postController
api.use (err, req, res, next) ->
	if err
		res.send
			success: false
			msg: err.message

app.use (req, res, next) ->
	console.log "Received request for #{req.path}"
	next()
app.use express.static $.publicdir
app.use '/api', api
