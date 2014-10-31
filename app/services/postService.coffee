async = require 'async'
_ = require 'underscore'

$ = require '../globals'
jobStore = $.stores.jobStore
postStore = $.stores.postStore
staticStore = $.stores.staticStore
module.exports = postService = {}

postService.create = (title, url, text, userId, username, done) ->
	job =
		dt: Date.now()
		authorId: userId
		author: username
		title: title
		url: url
		text: text

	jobStore.pushPostJob job, (err) ->
		done err

postService.reply = (rootId, parentId, title, text, userId, username, done) ->
	job =
		dt: Date.now()
		authorId: userId
		author: username
		rootId: rootId
		parentId: parentId
		title: title
		text: text

	jobStore.pushPostJob job, (err) ->
		done err

postService.vote = (postId, userId, done) ->
	job =
		dt: Date.now()
		voterId: userId
		postId: postId

	jobStore.pushVoteJob job, (err) ->
		done err
