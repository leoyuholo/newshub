fs = require 'fs'
path = require 'path'
async = require 'async'
_ = require 'underscore'

$ = require '../globals'
redisClient = $.redisClient
module.exports = postStore = {}

idKey = 'postid'
hPostKey = 'post'
zNewKey = 'postnew'
zReplyKey = 'postreply'
zScoreKey = 'postscore'

sVoteKey = (id) ->
	return "postvote:#{id}"

hTreeKey = (id) ->
	return "posttree:#{id}"

postStore.getCCnt = (id, done) ->
	redisClient.multi()
		.hget(hTreeKey(id), -1)
		.hvals(hTreeKey(id))
		.exec (err, replies) ->
			done err, if !replies[1] then 0 else replies[1].reduce(( (s, v) -> return s + +v), 0) - (replies[0] || 0)

postStore.getVCnt = (id, done) ->
	redisClient.scard sVoteKey(id), done

postStore.getVotes = (id, done) ->
	redisClient.smembers sVoteKey(id), done

getBasicPost = (id, done) ->
	redisClient.hget hPostKey, id, (err, json) ->
		done err, JSON.parse(json)

getPost = (id, done) ->
	async.parallel [
		_.partial getBasicPost, id
		_.partial postStore.getCCnt, id
		_.partial postStore.getVotes, id
	], (err, results) ->
		if results[0]
			post = results[0]
			post.ccnt = results[1]
			post.votes = results[2]
			post.vcnt = post.votes.length
		done err, post

getPostList = (key, start, end, done) ->
	redisClient.zrevrange key, start, end, (err, ids) ->
		return done err, [] if !ids || ids.length < 1

		async.map ids, getPost, done

postStore.getNewPostList = _.partial getPostList, zNewKey
postStore.getNewReplyList = _.partial getPostList, zReplyKey
postStore.getTopPostList = _.partial getPostList, zScoreKey

postStore.expireFromList = (listMaxLen, listMinScore, done) ->
	redisClient.multi()
		.zremrangebyrank(zReplyKey, listMaxLen, '+inf')
		.zremrangebyrank(zNewKey, listMaxLen, '+inf')
		.zrangebyscore(zScoreKey, '-inf', listMinScore)
		.zremrangebyrank(zReplyKey, listMaxLen, '+inf')
		.zremrangebyrank(zNewKey, listMaxLen, '+inf')
		.zremrangebyscore(zScoreKey, '-inf', listMinScore)
		.exec( (err, replies) ->
			ids = _.union(replies[0], _.intersection(replies[1], replies[2]))
			redisClient.hdel hPostKey, ids, done
		)

postStore.setScore = (id, score, done) ->
	redisClient.zadd zScoreKey, score, id, done

postStore.updateScore = (post, done) ->
	$.computeScore post, (err, post) ->
		postStore.setScore post.id, post.score, (err) ->
			done err, post

postStore.createPost = (post, done) ->
	redisClient.incr idKey, (err, id) ->
		post.id = id
		post.rootId = id
		post.parentId = id
		redisClient.multi()
			.hset(hPostKey, id, JSON.stringify post)
			.zadd(zNewKey, post.dt, id)
			.zadd(zScoreKey, 1, id)
			.exec( (err) ->
				done err, post
			)

propagateCCnt = (post, done) ->
	async.whilst ( () ->
		return !!post.parentId
	), ( (done) ->
		redisClient.multi()
			.hincrby(hTreeKey(post.parentId), post.id, 1)
			.hget(hTreeKey(post.parentId), -1)
			.exec( (err, replies) ->
				post =
					id: post.parentId
					parentId: replies[1]
				done err
			)
	), done

postStore.createReply = (post, done) ->
	redisClient.incr idKey, (err, id) ->
		post.id = id
		redisClient.multi()
			.hset(hPostKey, id, JSON.stringify post)
			.zadd(zReplyKey, post.dt, id)
			.hset(hTreeKey(id), -1, post.parentId)
			.exec( (err) ->
				return done err, post if err
				propagateCCnt post, (err) ->
					done err, post
			)

postStore.createVote = (vote, done) ->
	redisClient.sadd [sVoteKey(vote.id)].concat(vote.votes), (err, count) ->
		# return [] if all votes are duplicated
		done err, if 0 == count then [] else vote
