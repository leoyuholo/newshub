app = angular.module 'newshub'

app.filter('brackets', () ->
	return (value) ->
		if value
			return '(' + value + ')'
		else
			return ''
)