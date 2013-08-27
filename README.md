Mess Up The Page
================

A LeapJS example that you can touch a character in the website.
To mess it up, add this code to your favorites.
```javascript
javascript:(function(){function leapJsLoaded(){if(typeof LeapManager=='undefined'){var app=document.createElement('script');app.setAttribute('src','https://raw.github.com/junichi-ishikura/mess-up-the-page/master/js/app.min.js');document.body.appendChild(app);}}if(typeof Leap=='undefined'){var leapJs=document.createElement('script');leapJs.setAttribute('src','https://js.leapmotion.com/0.2.0/leap.min.js');leapJs.onload=leapJsLoaded;document.body.appendChild(leapJs)}else{leapJsLoaded();}}());
```
Have fun!

Tested only Google Chrome 29.

* Leap Motion : https://www.leapmotion.com/
* leap.js : http://js.leapmotion.com/
* Vimeo : https://vimeo.com/73119656
