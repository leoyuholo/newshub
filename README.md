#NewsHub
[live demo](http://newshub.leoyuholo.com)

example of `config.json`
```
{
	"port": 8000,
	"sessionSecret": "newshub secret",
	"redis": {
		"host": "127.0.0.1",
		"port": 6379
	},
	"aws": {
		"accessKeyId": "AKID",
		"secretAccessKey": "SECRET",
		"region": "ap-northeast-1",
		"bucket": "newshub.leoyuholo.com"
	}
}
```