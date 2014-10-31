$ = require '../globals'
redisClient = $.redisClient
module.exports = jobStore = {}

postJobKey = 'postJobs'
voteJobKey = 'voteJobs'

pushJob = (key, job, done) ->
	redisClient.rpush key, JSON.stringify(job), done

jobStore.pushPostJob = (job, done) ->
	pushJob postJobKey, job, done

jobStore.pushVoteJob = (job, done) ->
	pushJob voteJobKey, job, done

popAll = (key, done) ->
	redisClient.llen(key, (err, length) ->
		return done err if err
		if length > 0
			redisClient.multi()
				.lrange(key, 0, length - 1)
				.ltrim(key, length, -1)
				.exec( (err, replies) ->
					return done err if err
					done(null, replies[0].map(JSON.parse))
				)
		else
			done null, []
	)

jobStore.popAllPostJobs = (done) ->
	popAll postJobKey, done

jobStore.popAllVoteJobs = (done) ->
	popAll voteJobKey, done
