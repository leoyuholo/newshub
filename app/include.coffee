fs = require 'fs'
path = require 'path'

include = (dir, recur) ->
	obj = {}

	fs.readdirSync(dir).forEach( (file) ->
		basename = path.basename file, path.extname(file)

		filePath = path.join dir, file
		lstat = fs.lstatSync filePath
		if lstat.isFile()
			obj[basename] = require filePath
		else if recur && lstat.isDirectory()
			obj[basename] = include filePath, recur
	)

	return obj

module.exports = include