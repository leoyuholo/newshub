$ = require '../globals'
emitter = $.emitter

whenWriteStatic = (filePath, data, obj) ->
	console.log('whenWriteStatic', filePath);

emitter.on('afterWriteStaticPost', whenWriteStatic)
emitter.on('afterWriteStaticList', whenWriteStatic)