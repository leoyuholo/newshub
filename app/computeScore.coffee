
computeScore = (post, done) ->
	age = Date.now() - post.dt
	if !post.vcnt || (post.vcnt < 1 && age < 3600000)
		post.score = 1
	else
		post.score = (1 + post.vcnt) / Math.pow(1 + age / 86400000, 4)
	done null, post

module.exports = computeScore