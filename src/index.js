'use strict';

var Elm = require('./Main.elm');
var mountNode = document.getElementById('elm-app');

var app = Elm.Main.embed(mountNode);
window.app = app

function debounce(func, wait, immediate) {
	var timeout;
	return function() {
		var context = this, args = arguments;
		var later = function() {
			timeout = null;
			if (!immediate) func.apply(context, args);
		};
		var callNow = immediate && !timeout;
		clearTimeout(timeout);
		timeout = setTimeout(later, wait);
		if (callNow) func.apply(context, args);
	};
};


app.ports.updateSlideshow.subscribe(function(data) {
  var direction = data[1]
  var element = document.getElementById(data[0])

  if (!element) return false

  var currentY = element.scrollLeft
  var screenWidth = window.innerWidth
  var newY = direction === 'Left' ? currentY - screenWidth :
    direction === 'Right' ? currentY + screenWidth :
    currentY

  element.scrollTo({ left: newY, behavior: 'smooth' })
})


app.ports.resetScrollPosition.subscribe(function(id) {
  if (document.body.clientWidth < 670) {
    return document.body.scrollTop = 0
  }

  var overlays = [].slice.call(document.querySelectorAll('.overlay'))

  overlays.map(function(overlay) {
    if (overlay.dataset.active == "False") {
      overlay.scrollTop = 0
    }
  })
})



app.ports.scrollOverlayDown.subscribe(function() {
    window.requestAnimationFrame(function() {
      // scroll active overlay to the bottom
      var activePage = document.querySelector('.active-page')
      if (activePage) activePage.scrollTop = activePage.scrollHeight
    })
})



app.ports.playAnimation.subscribe(function() {
  return;
  window.requestAnimationFrame(function() {

    // show animationFrame, and then hide it when done
    var animationWrapper = document.getElementById('animation-wrapper')
    animationWrapper.style.display = 'block'
    var totalDuration = 5800
    window.setTimeout(function() {
      animationWrapper.style.display = 'none'
    }, totalDuration)

    var animations = [ 'bg' , 'effects' , 'tagline' ]

    animations.forEach(function(animationPath) {
      var delay = animationPath === 'effects' ? 4000 : 0

      window.setTimeout(function() {
        var animation = bodymovin.loadAnimation({
          container: document.getElementById(animationPath),
          path: '/animation/' + animationPath + '.json',
          renderer: 'svg',
          loop: false,
          autoplay: true,
        })
      }, delay)
    })
  })
})

