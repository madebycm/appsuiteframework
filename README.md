appsuiteframework
=================

The fast, easy and lightweight framework for rapidly creating swift apps that looks great on all devices.

Current version: 0.1 (while Zepto.js is the recommended library to use for performance reasons it is also fully compatible with jQuery)

#Userguide

madebycm AppSuite is a framework that favors convention over configuration.

# Defining views

Simply put the file under ```public/elephants.html```. A view does not need a controller to function.

# Defining controllers

Simply put the file under ```controllers/ElephantsController.coffee```

Initialize the controller with the following pattern:

```
App.ctrl.elephants =
  feed:  ->
    return "Yum, I like food"
```

Now go to ```http://url#elephants``` to see everything in action. Simple as that.

## Every controller supports defining an ```_init()``` method.

This method will always run first in the app suite ```runtime```.

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



# Triggering controller actions from the view

In ```public/elephants.html```, just create an element with the ```wAction``` attribute:

```<button wAction="feed">Feed the elephant</button>```

The ```wAction``` attribute supports special actions. A special action is always defined by starting its name with an underscore.

Controllers can be overriden by supplying a ```wController``` attribute:

```
<button wController="lions" wAction="feed">Feed the elephant</button>
<!-- will actually feed the lions -->
```

# Hot passing data
This works like Angulars's $scope.$apply, but in a much nicer fashion.

To hot pass data from a controller to another, simply write:
```$hotpass hello:world```

# Accessing the run time
To hot pass data directly into the current state, simply hot pass as described above, then just do a re-run of the runtime like this: ```App.runtime()```

```App.runtime()``` returns a promise, so you'll be able to write nice, async code in an easy matter

```
App.runtime().then ->
  # do some cool stuff with the DOM
```

*Note* - if you'd like to hot pass data in the ```_init()``` method of a controller, supply a first argument to ```runtime`` so it doesn't end up in an infinite loop:


# Magic wizard forms

Create step wizards with pure DOM.

Code example:

```
<div class="wStep step-1">
  <p>
    Heisann, {{username}}!<br>
    Jeg er wingme.
  </p>
  <p>
    Det ser ikke ut som du har brukt appen før.
    Da er det på tide å MEKKE en konto!!
  </p>
  <button wAction="_step->2">Okey, mos på!</button>
</div>
<div class="wStep step-2">
  Nå er du i steg 2.<br>
  Her kan vi be deg om mer info. 
  Vennligst fortsett, {{username}}!
  <br><button wAction="_stepBack">Tilbake!</button>
  <button style="color:#4dd963;" wAction="_step->3">Fortsett!</button>
</div>
<div class="wStep step-3">
  All right, {{username}}, nå får du en brukerkonto!<br>  
  <button wAction="confirm">Bekreft!</button>
</div>
```

# Dev notes

See baa9e02d679ce84b507ef2ba94dcf3e64d668016 for info on how to modularize API when it grows bigger.