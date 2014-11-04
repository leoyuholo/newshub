path = require 'path'

AWS = require 'aws-sdk'

$ = require '../globals'
emitter = $.emitter

if aws = $.config.aws
	s3Bucket = new AWS.S3(
		accessKeyId: aws.accessKeyId
		secretAccessKey: aws.secretAccessKey
		region: aws.region
		params:
			Bucket: aws.bucket
	)
else
	console.log('Missing aws config, static resources will not be copied to S3.');

whenWriteStatic = (filePath, data, obj) ->
	if s3Bucket
		s3Key = path.relative $.publicdir, filePath
		s3Bucket.putObject({Key: s3Key, Body: data}, (err, data) ->
			if (err)
				console.log("Error uploading data to S3: ", err);
			else
				console.log("Successfully uploaded data to #{s3Key}");
		)

emitter.on('afterWriteStaticPost', whenWriteStatic)
emitter.on('afterWriteStaticList', whenWriteStatic)