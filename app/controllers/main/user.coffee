###
  Copyright (c) 2015 Abi Hafshin
  see README.md
###

module.exports = (Controller) ->
  class UserController extends Controller

    actionLogin: ->
      @render('login')

    actionLogout: ->
      @req.logout()
      @redirect('main.default.index')
