AppSuite Framework
=================

The fast, easy and lightweight framework for rapidly creating swift apps that looks great on all devices.

Current version: 0.1 (while Zepto.js is the recommended library to use for performance reasons it is also fully compatible with jQuery)

Please note that this framework is in active development. While it is being used for production apps published on the App Store and Google Play, it should not be considered production ready for the general public ... just yet.

#User guide

madebycm AppSuite is a framework that favors convention over configuration. All examples in this guide is currently written in CoffeeScript, but you're of course free to use plain ol' vanilla code if you'd like.

# Views
### Defining views

Simply put the file under ```public/elephants.html```. A view does not need a controller to function.

### Special attributes

Views support a range of special DOM attributes.
These are:

#### wAction
Links the value to a controller function

#### wController
Provides you with the possibility to manually override the set controller.

#### wUrl
Rewrites to an ```onclick``` javascript event for redirecting. Primarily intended for use with buttons.

#### wSupply
Only used when ```wAction``` contains a special action. Used to supply a controller action with the special action. 

#### wBind
Provides data binding support. Currently supported on ```ìnput``` fields

# Controllers
### Defining controllers
- Put the file under ```controllers/ElephantsController.coffee```
- Initialize the controller with the following pattern:

```
App.ctrl.elephants =
  feed:  ->
    return "Yum, I like food"
```

Now go to ```http://url#elephants``` to see everything in action. Simple as that.

The ```runtime``` will automatically look for controllers following the preferred pattern (```App.ctrl.[ctrlname]```) and do appropriate bindings

### Initialization method.
In your controller simply define a method named ```_init()``` (note the underscore)

This method will always run in the AppSuite ```runtime```.

## Custom view override

Although the app suite favors convention over configuration, it will give you the possibility to to customize its application architecture when you need to.

In a controller, you can override the view it will look for by supplying the ```view``` property before defining any other actions.

For example, for a controller that should log an user out, we don't need a specific view for that. What we want to do here is simply show the login page as soon as possible. Example code:

```
App.ctrl.logout =
  view: 'login' # will now load public/login.html instead
  _init: ->
    console.log 'Logging you out'
    localStorage.clear()
```



## Triggering controller actions from the view

In ```public/elephants.html```, just create an element with the ```wAction``` attribute:

```<button wAction="feed">Feed the elephant</button>```

The ```wAction``` attribute supports special actions. A special action is always defined by starting its name with an underscore.

Controllers can be overriden by supplying a ```wController``` attribute:

```
<button wController="lions" wAction="feed">Feed the elephant</button>
<!-- will actually feed the lions -->
```

# Data binding
## Hot passing
This works like Angulars's $scope.$apply, but in a much nicer fashion.
To hot pass data from a controller to another, simply write:

```$hotpass hello:world```

## The runtime
To hot pass data directly into the current state, simply hot pass as described above, then just do a re-run of the runtime like this: ```App.runtime()```

```App.runtime()``` returns a promise, so you'll be able to write nice, async code in an easy matter

```
App.runtime().then ->
  # do some cool stuff with the DOM
```

*Note* - if you'd like to hot pass data in the ```_init()``` method of a controller, supply a first argument to ```runtime`` so it doesn't end up in an infinite loop:


# Special components
## Magic wizard forms

Create step wizards with pure DOM.

Code example:

```
<div class="wStep step-1">
  <p>
    Hello, {{username}}!<br>  </p>
  <p>
    Welcome to the app. Ready to set up your account?
  </p>
  <button wAction="_step->2">Yes!</button>
</div>
<div class="wStep step-2">
  This is step 2.<br>
  Please continue, {{username}}!
  <br><button wAction="_stepBack">Go back!</button>
  <button style="color:#4dd963;" wAction="_step->3">Continue!</button>
</div>
<div class="wStep step-3">
  All right, {{username}}, you're all ready to go.<br>  
  <button wAction="confirm">Confirm</button>
</div>
```