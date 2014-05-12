// madebycm AppSuite Framework
// v0.1.3a
(function() {
  var applyScope, getCurrentController, loadRoute, runtime, setUpListeners,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  this.$hotpass = function(data) {
    return App.HOT_PASS = data;
  };

  this.App = {
    debug: 1,
    stepWizardDebug: 0,
    ctrl: {},
    CURRENT_CTRL: '',
    HOT_PASS: {},
    RUNTIME_COUNTER: 0,
    BOUND_EVENTS: []
  };

  setUpListeners = function() {
    var counterDataBinds, counterNormalActions, counterSpecialActions, doTheBind, pageHasStepWizardComponent, stepWizardComponents, _stepWizardCounter;
    counterNormalActions = 0;
    counterSpecialActions = 0;
    counterDataBinds = 0;
    pageHasStepWizardComponent = false;
    _stepWizardCounter = 1;
    doTheBind = function(el, attr) {
      var controllerToBind, wController;
      wController = el.attr('wController');
      controllerToBind = wController != null ? wController : App.CURRENT_CTRL;
      if (__indexOf.call(App.BOUND_EVENTS, controllerToBind) < 0) {
        App.BOUND_EVENTS.push(controllerToBind);
        return el.bind('click', function(e) {
          return App.ctrl[controllerToBind][attr](e);
        });
      }
    };
    $('*').each(function() {
      var goToStep, isStepWizard, isStepWizardComponent, specialAction, thisBinderDefault, thisBinderText, wAction, wBind, wSupply, wUrl;
      wAction = $(this).attr('wAction');
      wUrl = $(this).attr('wUrl');
      wSupply = $(this).attr('wSupply');
      wBind = $(this).attr('wBind');
      isStepWizard = $(this).hasClass('.wStep');
      if (wSupply) {
        doTheBind($(this), wSupply);
      }
      if (wAction) {
        if (wAction[0] === '_') {
          counterSpecialActions++;
          specialAction = wAction.split('->');
          switch (specialAction[0]) {
            case '_step':
              goToStep = specialAction[1];
              $(this).bind('click', function(e) {
                if (!e.isDefaultPrevented()) {
                  $('.wStep.step-' + (goToStep - 1)).hide();
                  $('.wStep.step-' + goToStep).show();
                  return _stepWizardCounter++;
                }
              });
              break;
            case '_stepBack':
              $(this).bind('click', function(e) {
                e.preventDefault();
                $('.wStep.step-' + _stepWizardCounter).hide();
                $('.wStep.step-' + (_stepWizardCounter - 1)).show();
                return _stepWizardCounter--;
              });
          }
        } else {
          counterNormalActions++;
          doTheBind($(this), wAction);
        }
      }
      if (wUrl) {
        $(this).attr('onclick', "window.location='#" + $(this).attr('wUrl') + "'");
        $(this).removeAttr('wUrl');
      }
      isStepWizardComponent = $(this).hasClass('wStep');
      if (isStepWizardComponent) {
        pageHasStepWizardComponent = true;
      }
      if (wBind) {
        if ($(this).prop('tagName') === 'INPUT') {
          counterDataBinds++;
          thisBinderText = $('.wBind-x-madebycm-' + $(this).attr('wBind'));
          thisBinderDefault = getCurrentController()[$(this).attr('wBind')];
          return $(this).on({
            'blur keyup change': function() {
              thisBinderText.text($(this).val());
              if ($(this).val().length === 0) {
                return thisBinderText.text(thisBinderDefault);
              }
            }
          });
        }
      }
    });
    if (App.debug) {
      console.log('Bound', counterNormalActions, counterNormalActions > 1 ? 'actions' : 'action');
      console.log('Bound', counterSpecialActions, 'special ' + (counterSpecialActions > 0 ? 'actions' : 'action'));
      console.log('Bound', counterDataBinds, 'data ' + (counterDataBinds > 0 ? 'bindings' : 'bind'));
    }
    if (pageHasStepWizardComponent) {
      stepWizardComponents = $('.wStep');
      if (App.debug) {
        console.log('Found', stepWizardComponents.length, 'step wiz components');
      }
      stepWizardComponents.each(function() {});
    }
    if (App.stepWizardDebug) {
      console.log('Step wizards will be shown in full');
      return $('.wStep').show();
    }
  };

  loadRoute = function(overridePath) {
    var page, pageToLoad, query, startPage;
    page = location.hash;
    startPage = 'front';
    if (overridePath) {
      if (overridePath) {
        pageToLoad = "public/" + overridePath + ".html";
      }
    } else {
      pageToLoad = (page.length > 0 ? 'public/' + (page.replace('#', '') + '.html') : "public/" + startPage + ".html");
    }
    App.CURRENT_CTRL = page.replace('#/', '').replace('#', '').replace('/', '');
    if (!page.length > 0) {
      App.CURRENT_CTRL = startPage;
    }
    if (overridePath === 'login') {
      App.CURRENT_CTRL = 'login';
    }
    if (getCurrentController()) {
      if (!(getCurrentController().view == null)) {
        pageToLoad = "public/" + (getCurrentController().view) + ".html";
      }
    }
    query = $.ajax({
      type: 'GET',
      url: pageToLoad,
      success: function(data) {
        applyScope(data);
        setUpListeners();
        return $('form').submit(function(e) {
          return e.preventDefault();
        });
      },
      error: function() {
        if (!getCurrentController()) {
          return $('.view').load('public/error.html');
        }
      }
    });
    return query;
  };

  applyScope = function(dom) {
    var allowedTypes, data, handle, handleFromController, handlebars, hasHandlebars, _i, _len, _ref, _ref1;
    data = dom;
    hasHandlebars = data.match(/{{.*?}}/g);
    if (hasHandlebars) {
      handlebars = hasHandlebars.map(function(x) {
        return x.match(/[\w\.]+/)[0];
      });
      allowedTypes = ['string', 'number'];
      for (_i = 0, _len = handlebars.length; _i < _len; _i++) {
        handle = handlebars[_i];
        if ((_ref = typeof getCurrentController()[handle], __indexOf.call(allowedTypes, _ref) < 0) || handle) {
          handleFromController = getCurrentController()[handle];
        }
        if (_ref1 = typeof getCurrentController()[handle], __indexOf.call(allowedTypes, _ref1) < 0) {
          handleFromController = handle;
        }
        if (App.HOT_PASS[handle] != null) {
          handleFromController = App.HOT_PASS[handle];
        }
        data = data.replace('{{' + handle + '}}', '<span class="wBind wBind-x-madebycm-' + handle + '">' + handleFromController + '</span>');
      }
    }
    return $('.view').html(data);
  };

  App.getCurrentController = getCurrentController = function() {
    if (!(App.ctrl[App.CURRENT_CTRL] == null)) {
      return App.ctrl[App.CURRENT_CTRL];
    }
  };

  App.runtime = runtime = function(skipFiringInitMethod) {
    return loadRoute().then(function() {
      if ((getCurrentController() != null) && (getCurrentController()._init != null) && !skipFiringInitMethod) {
        getCurrentController()._init();
        if (App.debug) {
          console.log("Fired init method in App.ctrl." + App.CURRENT_CTRL);
        }
      }
      if (getCurrentController()) {
        if (!(getCurrentController().view == null)) {
          App.CURRENT_CTRL = getCurrentController().view;
        }
      }
      if (App.debug) {
        return console.log("[OK] Runtime ~" + (++App.RUNTIME_COUNTER));
      }
    });
  };

  $(document).ready(function() {
    if (navigator.userAgent.toLowerCase().indexOf('chrome') > -1) {
      console.log('%cAppSuite 0.1.3', 'font-size:20px;color:#fff;text-shadow:0 1px 0 #ccc,0 2px 0 #c9c9c9,0 3px 0 #bbb,0 4px 0 #b9b9b9,0 5px 0 #aaa,0 6px 1px rgba(0,0,0,.1),0 0 5px rgba(0,0,0,.1),0 1px 3px rgba(0,0,0,.3),0 3px 5px rgba(0,0,0,.2),0 5px 10px rgba(0,0,0,.25),0 10px 10px rgba(0,0,0,.2),0 20px 20px rgba(0,0,0,.15);');
    }
    runtime();
    return FastClick.attach(document.body);
  });

  window.onhashchange = function() {
    return runtime();
  };

}).call(this);
