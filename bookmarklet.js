javascript:(function () {

  function leapJsLoaded() {
    if (typeof LeapManager == 'undefined') {
      var app = document.createElement('script');
      app.setAttribute('src', '/app.min.js');
      document.body.appendChild(app);
    }
  }

  if (typeof Leap == 'undefined') {
    var leapJs = document.createElement('script');
    leapJs.setAttribute('src', 'https://js.leapmotion.com/0.2.0/leap.min.js');
    leapJs.onload = leapJsLoaded;
    document.body.appendChild(leapJs)
  } else {
    leapJsLoaded();
  }

}());