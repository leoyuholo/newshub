async = require 'async'
_ = require 'underscore'

$ = require '../globals'

refreshList = (getList, type, start, end, page, done) ->
	getList start, end, (err, posts) ->
		if posts && posts.length > 0
			list =
				type: type
				page: page
				list: posts
			$.stores.staticStore.writeStaticList list, done
		else
			done null

refreshLists = (getList, type, done) ->
	step = 30
	async.parallel ([1..5].map (i) ->
		_.partial refreshList, getList, type, (i-1)*step, i*step-1, i
	), done

refreshAllLists = (done) ->
	postStore = $.stores.postStore
	async.parallel [
		_.partial refreshLists, postStore.getNewPostList, 'new'
		_.partial refreshLists, postStore.getNewReplyList, 'reply'
		_.partial refreshLists, postStore.getTopPostList, 'top'
	], done

run = () ->
	setInterval (->
		refreshAllLists( (err) ->
			console.log('listTask, err:', err) if err
		)
	), $.config.refreshListInterval

run()