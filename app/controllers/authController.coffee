$ = require '../globals'

authService = $.services.authService

router = $.express.Router()

router.post '/login', authService.login

router.post '/signup', authService.signup

router.get '/logout', authService.logout

module.exports = router