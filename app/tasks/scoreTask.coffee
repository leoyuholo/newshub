async = require 'async'

$ = require '../globals'
postStore = $.stores.postStore

timebase = 7200000

run = () ->
	setInterval ( () ->
		rand = Math.random() * 150
		postStore.getTopPostList(rand, rand + 1, (err, posts) ->
			async.each posts, ( (post, done) ->
				postStore.updateScore post, done
			), (err) ->
				console.log('scoreTask err:', err) if err
		)
	), 30000

run()