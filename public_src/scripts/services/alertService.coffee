app = angular.module 'newshub'

app.service('alertService', ($rootScope, $timeout) ->

	alertService = {}

	timeout = {}

	alertService.defaultTimeout = defaultTimeout = 2000

	alert = (target, message, time, done) ->
		$rootScope.alerts[target] = message
		time = time || defaultTimeout
		if time > 0
			$timeout.cancel timeout[target]
			timeout[target] = $timeout ( () ->
				$rootScope.alerts[target] = ''
			), time
			timeout[target].finally done
		else
			callFn done, null

	alertService.success = (message, time, done) ->
		alert 'alertSuccess', message, time, done

	alertService.error = (message, time, done) ->
		alert 'alertDanger', message, time, done

	alertService.clear = () ->
		$rootScope.alerts = {}
		$timeout.cancel t for k, t of timeout

	return alertService
)