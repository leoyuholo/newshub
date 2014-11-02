async = require 'async'
_ = require 'underscore'

$ = require '../globals'
postStore = $.stores.postStore
staticStore = $.stores.staticStore
jobStore = $.stores.jobStore

processPostJobs = (jobs, done) ->
	return done null, [] if !jobs || jobs.length < 1

	async.map(jobs, ( (job, done) ->
		if job.parentId
			post =
				dt: job.dt
				author: job.author
				authorId: job.authorId
				rootId: job.rootId
				parentId: job.parentId
				title: job.title
				text: job.text
			postStore.createReply post, done
		else
			post =
				dt: job.dt
				author: job.author
				authorId: job.authorId
				title: job.title
				url: job.url
				src: job.src
				text: job.text
			postStore.createPost post, done
	), (err, posts) ->
		async.map posts, staticStore.writeStaticPost, done
	)

processVoteJobs = (jobs, done) ->
	return done null, [] if !jobs || jobs.length < 1
	
	votesMap = jobs.reduce ((votes, job) ->
		votes[job.postId] = votes[job.postId] || []
		votes[job.postId].push job.voterId
		return votes
	), {}

	votes = _.map votesMap, (voterIds, postId) ->
		return {id: postId, votes: voterIds}

	async.map votes, postStore.createVote, (err, votes) ->
		done err, _.compact votes

refreshPost = (postId, child, done) ->
	staticStore.readStaticPost postId, (err, post) ->
		if child
			post.children = post.children || {}
			post.children[child.id] = child

		async.parallel([
			_.partial postStore.getCCnt, postId
			_.partial postStore.getVotes, postId
		], (err, results) ->
			post.ccnt = results[0] || 0
			post.votes = results[1] || []
			post.vcnt = post.votes.length
			staticStore.writeStaticPost post, done
		)

refreshPosts = (posts, done) ->
	async.whilst ( () ->
		return posts.length > 0
	), ( (done) ->
		async.map posts, ( (post, done) ->
			if !post.parentId
				# vote
				refreshPost post.id, null, (err, post) ->
					return done err, post if post.id != post.parentId
					postStore.updateScore post, done
			else if post.parentId != post.id
				# propagate
				refreshPost post.parentId, post, done
			else
				# reached root
				done null, null	
		), (err, nextPosts) ->
			posts = _.compact nextPosts
			done err
	), done

refreshAllPosts = (done) ->
	async.parallel [
		_.partial async.waterfall, [jobStore.popAllPostJobs, processPostJobs]
		_.partial async.waterfall, [jobStore.popAllVoteJobs, processVoteJobs]
	], (err, results) ->
		refreshPosts results[0].concat(results[1]), done

run = () ->
	setInterval (->
		refreshAllPosts( (err) ->
			console.log('postTask, err:', err) if err
		)
	), $.config.refreshPostInterval

run()