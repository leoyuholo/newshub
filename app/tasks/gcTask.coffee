$ = require '../globals'

run = () ->
	setInterval ( () ->
		$.stores.postStore.expireFromList 300, 0.125, (err) ->
			console.log('gcTask err:', err) if err
	), $.config.gcInterval

run()