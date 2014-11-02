fs = require 'fs'
path = require 'path'

fsEx = require 'fs-extra'

$ = require '../globals'
module.exports = staticStore = {}

staticPath = path.join $.publicdir, 'static/'

makePath = () ->
	dirs = [
		'post'
		'list'
		'list/new'
		'list/top'
		'list/reply'
	]
	dirs = dirs.map (dir) ->
		return path.join staticPath, dir
	dirs.forEach (dir) ->
		fsEx.ensureDirSync dir, 0o770

makePath()

staticStore.postPath = (id) ->
	return path.join staticPath, "post/#{id}.json"

listPath = (type, page) ->
	return path.join staticPath, 'list/', type, "#{if page && page > 1 then page else 'index'}.json"

staticStore.readStaticPost = (id, done) ->
	fs.readFile staticStore.postPath(id), {encoding: 'utf-8'}, (err, data) ->
		done err, JSON.parse(data)

staticStore.writeStaticPost = (post, done) ->
	post.updateDt = Date.now()
	fs.writeFile staticStore.postPath(post.id), JSON.stringify(post), (err) ->
		done err, post

staticStore.writeStaticList = (list, done) ->
	list.updateDt = Date.now()
	fs.writeFile listPath(list.type, list.page), JSON.stringify(list), (err) ->
		done err, list