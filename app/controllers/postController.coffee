$ = require '../globals'

postService = $.services.postService

commonCb = (res, next) ->
	return (err) ->
		if err
			next new Error 'Server error.'
		else
			res.send
				success: true

router = $.express.Router()

router.post '/create', (req, res, next) ->
	title = req.param 'title'
	url = req.param 'url'
	text = req.param 'text' if !url

	postService.create title, url, text, req.user.id, req.user.username, commonCb(res, next)

router.post '/reply', (req, res, next) ->
	rootId = req.param 'rootId'
	parentId = req.param 'parentId'
	title = req.param 'title'
	text = req.param 'text'

	postService.reply rootId, parentId, title, text, req.user.id, req.user.username, commonCb(res, next)

router.post '/vote', (req, res, next) ->
	postId = req.param 'postId'

	postService.vote postId, req.user.id, commonCb(res, next)

module.exports = router