#NewsHub

example of `config.json`
```
{
	"redis": {
		"host": "127.0.0.1",
		"port": 6379
	},
	"port": 8000,
	"sessionSecret": "newshub secret",
	"refreshPostInterval": 1000,
	"refreshListInterval": 5000,
	"refreshScoreInterval": 30000,
	"gcInterval": 1800000
}
```