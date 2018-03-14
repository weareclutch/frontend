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



function getParallaxPositions() {
  var elements = [].slice.call(document.querySelectorAll('.parallax'))

  app.ports.getParallaxPositions.send(
    elements.map(function(element) {
      var [ , id ] = /parallax-([^\s]+)/.exec(element.className)
      var closestWrapper = element.closest('.page-wrapper')
      var { top } = element.getBoundingClientRect()

      return {
        y: closestWrapper.scrollTop + top,
        id
      }
    })
  )
}

function setWindowDimensions() {
  app.ports.setWindowDimensions.send([window.innerWidth, window.innerHeight])
}


window.onresize = debounce(function() {
  var activeOverlay = document
    .querySelector('.overlay.active')

  setWindowDimensions()
  getParallaxPositions()

  if (!activeOverlay) {
    return null
  }

  var pos = activeOverlay.getBoundingClientRect()
  app.ports.repositionCase.send(pos)
}, 400)




app.ports.getCasePosition.subscribe(function(id) {
  var activePage = document
    .querySelector('.page-wrapper.active')
 
  if (!activePage) {
    return null
  }

  var overlayNode = activePage.querySelector('.overlay-' + id)


  if (overlayNode) {
    var pos = overlayNode.getBoundingClientRect()
    app.ports.newCasePosition.send(pos)
  }
})



app.ports.showHomeIntro.subscribe(function(lottiePath) {
  window.requestAnimationFrame(function() {
    // scroll to the bottom
    var home = document.querySelector('.page-wrapper.home')
    home.scrollTop = home.scrollHeight - window.innerHeight * 2

    getParallaxPositions()
    setWindowDimensions()

    // play the lottie animation if its available
    if (lottiePath) {
      var animation = bodymovin.loadAnimation({
        container: document.getElementById('home-animation'),
        path: lottiePath,
        renderer: 'svg/canvas/html',
        loop: true,
        autoplay: true,
        name: "Hello World"
      })
    }
  })
})
