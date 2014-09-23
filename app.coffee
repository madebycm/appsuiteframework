# nice alias hotpass function
@.$hotpass = (data) ->
  App.HOT_PASS = data

@.App =

  # Enable global debugging
  debug                          : 1
  # This collapses every step wizard
  stepWizardDebug                : 0

  ctrl: {} #object map for controllers
  CURRENT_CTRL: '' #stores current controller

  # Hot data passing
  # Pass data to avoid the need of a refresh
  # e.g. when reading default values in a controller from localStorage
  # Hot passing works on all data binds declared with {{like_this}}

  # to immediately update all data on a page,
  # just call App.runtime
  # (kind of like Angular's $scope.$apply)
  HOT_PASS: {}
  ############

  # keep track of how many times we run runtime, run run run, runtime
  RUNTIME_COUNTER: 0

  # keep track of all events we bound so as to not rebind them
  BOUND_EVENTS: []

#
# function setUpListeners()
# Registers appropriate events on the dom by looking for a certain set of special DOM-tags/attributes
#
setUpListeners = ->
  
  counterNormalActions = 0
  counterSpecialActions = 0
  counterDataBinds = 0

  pageHasStepWizardComponent = false
  _stepWizardCounter = 1 # you always start on step 1

  doTheBind = (el,attr) ->
    # allow overriding of controller
    wController = el.attr 'wController'
    # figure out which controller to bind
    controllerToBind = if wController? then wController else App.CURRENT_CTRL
    #
    # Bind the action
    # if you supply a wController attribute on the dom it will use that instead of the one stored in App.CURRENT_CTRL
    # App.CURRENT_CTRL is modified on each page load, and it reads the value from location.hash
    # to determine controller (convention over configuration)
    #    
    # @ todo implement touch instead of click

    # Only bind this if it's not already bound
    # and never rebind if the controller is ui
    if attr not in App.BOUND_EVENTS
     App.BOUND_EVENTS.push attr
     el.bind 'click', (e) -> App.ctrl[controllerToBind][attr](e)
    else
      if controllerToBind != 'ui'
        App.BOUND_EVENTS.push attr
        el.bind 'click', (e) -> App.ctrl[controllerToBind][attr](e)
      else
        console.log '[Not rebound]', attr, 'from', controllerToBind if App.debug?

  $('*').each ->
    
    # main action (can contain special actions)
    wAction = $(@).attr('wAction')
    # wUrl, just rewrite to an onclick url (for use with buttons, mainly)
    wUrl = $(@).attr('wUrl')
    # supply action (to be used when combining with special actions)
    wSupply = $(@).attr('wSupply')# allow overriding of controller
    # data binding
    wBind = $(@).attr('wBind')

    isStepWizard = $(@).hasClass('.wStep')

    if wSupply
      doTheBind $(@), wSupply

    if wAction
      # got a wAction
      # is this a special action? (special wActions begins with "_")
      if wAction[0] == '_'
        counterSpecialActions++
        specialAction = wAction.split '->' # find out what special action this is
        
        switch specialAction[0]

          when '_step'
            goToStep = specialAction[1]
            $(@).bind 'click', (e) ->

              # TODO push states!
              if !e.isDefaultPrevented()
                
                $('.wStep.step-'+(goToStep-1)).hide()
                $('.wStep.step-'+goToStep).show()

                _stepWizardCounter++

          when '_stepBack'

            $(@).bind 'click', (e) ->
              e.preventDefault()

              $('.wStep.step-'+(_stepWizardCounter)).hide()
              $('.wStep.step-'+(_stepWizardCounter-1)).show()

              _stepWizardCounter--

       else
        counterNormalActions++
        doTheBind $(@), wAction

    if wUrl
      $(@).attr('onclick', "window.location='#"+$(@).attr('wUrl')+"'")
      $(@).removeAttr 'wUrl'

    # look for step wizard components
    isStepWizardComponent = $(@).hasClass('wStep')

    if isStepWizardComponent
      pageHasStepWizardComponent = true
    
    if wBind
      if $(@).prop('tagName') == 'INPUT' # for now we only support binding input fields (what else would you bind? time will tell, no?)        
        counterDataBinds++
        
        thisBinderText = $('.wBind-x-madebycm-'+$(@).attr 'wBind')
        thisBinderDefault = getCurrentController()[$(@).attr 'wBind']

        $(@).on 'blur keyup change': -> # keydown is faster, but prone to length inaccuracy
          # reset value on complete backspace
          thisBinderText.text($(@).val())

          if $(@).val().length == 0 # reset to default value from controller
            thisBinderText.text(thisBinderDefault)
  if App.debug
    (console.log 'Bound', counterNormalActions, if counterNormalActions > 1 then 'actions' else 'action')
    (console.log 'Bound', counterSpecialActions, 'special ' + if counterSpecialActions > 0 then 'actions' else 'action')
    (console.log 'Bound', counterDataBinds, 'data ' + if counterDataBinds > 0 then 'bindings' else 'bind')

  # set up step wizard components

  if pageHasStepWizardComponent
    stepWizardComponents = $('.wStep')
    console.log 'Found', stepWizardComponents.length, 'step wiz components' if App.debug
    stepWizardComponents.each ->

  if App.stepWizardDebug
    console.log 'Step wizards will be shown in full'
    $('.wStep').show()

#
# function loadRoute()
# Fires an AJAX request looking for either a) the page in #hashtag or b) the page in optional parameter overridePath
#
loadRoute = (overridePath) ->
  page = location.hash
    
  # default view and controller will be set to this
  startPage = 'front'

  if overridePath then pageToLoad = "public/#{overridePath}.html" if overridePath
  else pageToLoad = (if page.length > 0 then 'public/'+(page.replace('#', '')+'.html') else "public/#{startPage}.html")

  # tidy up these three lines ;)
  App.CURRENT_CTRL = page.replace('#/', '').replace('#', '').replace('/', '')
  App.CURRENT_CTRL = startPage if !page.length > 0
  App.CURRENT_CTRL = 'login' if overridePath == 'login'

  # the view might be overriden in the controller!
  if getCurrentController()
    pageToLoad = "public/#{getCurrentController().view}.html" unless !getCurrentController().view?

  query = $.ajax
    type: 'GET'
    url: pageToLoad,
    success: (data) ->

      applyScope(data)
      setUpListeners()
      
      # rethink this approach maybe?      
      $('form').submit (e) ->
        e.preventDefault()

    error: ->

      # ok, view not found.
      # but, we will allow this to fire if we have a controller!
      # maybe this is not in the right place, as you get a 404 anyway
      
      $('.view').load 'public/error.html' unless getCurrentController()

  query # return the promise query

# Function applyScope
# Takes original content and processes it with handlebars data-binding magic
#
# @TODO (HIGH PRIORITY)
# make this method work with already processed {{handlebars}} tags
# so that we can run it on an already existing page, without the need to grab original source again...
#
# Possible solutions
# 1 - keep a copy of the original content in memory
# 2- Modify the solution to take wBind-x-madebycm tags into consideration
#
applyScope = (dom) ->
  data = dom # <- lazy shortcut 
  # check for handlebars
  hasHandlebars = data.match(/{{.*?}}/g)
  #hasHandlebars = data.match(/{{\s*[\w\.]+\s*}}/g)
  if hasHandlebars

    # capture handlebars
    handlebars = hasHandlebars.map (x) -> x.match(/[\w\.]+/)[0]
    

    # these data types are allowed
    allowedTypes = ['string', 'number']

    # remove original string from source
    for handle in handlebars
      # check if we have a default handle string value in the controller
      handleFromController = getCurrentController()[handle] if typeof getCurrentController()[handle] not in allowedTypes or handle
      # disallow use of functions
      handleFromController = handle if typeof getCurrentController()[handle] not in allowedTypes

      # last, if this is a hot data pass, use that instead
      # supports an object of hot passed data
      if App.HOT_PASS[handle]? then handleFromController = App.HOT_PASS[handle]
      #console.log getCurrentController()[handle] or handle
      data = data.replace '{{'+handle+'}}', '<span class="wBind wBind-x-madebycm-'+handle+'">'+handleFromController+'</span>'

  $('.view').html(data)

# METHODS


#
# function getCurrentController
# @returns OBJECT of the current active controller
#
App.getCurrentController = getCurrentController = ->
  return App.ctrl[App.CURRENT_CTRL] unless !App.ctrl[App.CURRENT_CTRL]?


# ENGINE

#
# function runtime()
#
# runtime fires on initial page load, and on hashchange
# 7 may, 2014; runtime is now exposed in window.App
# this means it can be called from anywhere, to rebind data
# pass "skipFiringInitMethod" parameter to .. skip firing the _init() methof of the current controller
#

App.runtime = runtime = (skipFiringInitMethod) ->

  # this here is not framework specific
  #route = 'login' if !localStorage.user and location.hash != "#signup"
  loadRoute().then -> # Your freshly baked DOM is now ready, sir!

    # fire controller init method
    if getCurrentController()? and getCurrentController()._init? and !skipFiringInitMethod
      getCurrentController()._init()
      console.log "Fired init method in App.ctrl.#{App.CURRENT_CTRL}" if App.debug

    # the controller might have been overriden from the view
    # put this after fire controller init method, so it can 
    # fire its original _init!!
    if getCurrentController()
      App.CURRENT_CTRL = getCurrentController().view unless !getCurrentController().view?

    # set up fast click (should we do this in loadRoute?)
    #FastClick.attach document.body

    console.log "[OK] Runtime ~#{++App.RUNTIME_COUNTER}" if App.debug

$(document).ready ->
  # this line only runs on Chrome
  console.log('%cAppSuite 0.1.3', 'font-size:20px;color:#fff;text-shadow:0 1px 0 #ccc,0 2px 0 #c9c9c9,0 3px 0 #bbb,0 4px 0 #b9b9b9,0 5px 0 #aaa,0 6px 1px rgba(0,0,0,.1),0 0 5px rgba(0,0,0,.1),0 1px 3px rgba(0,0,0,.3),0 3px 5px rgba(0,0,0,.2),0 5px 10px rgba(0,0,0,.25),0 10px 10px rgba(0,0,0,.2),0 20px 20px rgba(0,0,0,.15);') if navigator.userAgent.toLowerCase().indexOf('chrome') > -1
  runtime()

  FastClick.attach document.body

# window.onscroll = (p) ->

  # this here is VERY badly optimized (fires 100123asd times)
  # if window.pageYOffset < 15
  #   $('footer').removeClass 'hide'
  #   setTimeout ->
  #     $('footer').addClass 'hide'
  #     console.log 'hidden'
  #   , 1000
  # else
  #   $('footer').addClass 'hide';

window.onhashchange =->
  runtime()