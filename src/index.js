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


app.ports.unbindAll.subscribe(function() {
  var aboutUsPage = document.getElementById('about-us-page')
  if (aboutUsPage) {
    aboutUsPage
      .parentElement
      .removeEventListener('scroll', aboutUsHandleScroll)
  }
})


app.ports.bindAboutUs.subscribe(function() {
  window.requestAnimationFrame(function() {
    var page = document.getElementById('about-us-page')
    if (!page) return false

    var animations = [].slice.call(page.querySelectorAll('.animation'))
    var animationNames = [ 'boost', 'think', 'rethink' ]

    if (animations) {
      animations.map(function(animation, index) {
        playAnimation([animation.id, animationNames[index]])
      })
    }

    page.parentElement.addEventListener('scroll', aboutUsHandleScroll)
  })
})



function aboutUsHandleScroll(e) {
  window.requestAnimationFrame(function() {
    var page = document.getElementById('about-us-page')
    if (!page) return false

    var wrapper = page.querySelector('.topics')
    var topics = [].slice.call(page.querySelectorAll('.topic'))
    var animationWrapper = page.querySelector('.animation-wrapper')
    var animations = [].slice.call(page.querySelectorAll('.animation'))

    // current scroll position from center of page to element
    var current = page.parentElement.scrollTop - wrapper.offsetTop + window.innerHeight / 2


    var activeElement = topics.reduce(function(acc, topic, index) {
      return topic.offsetTop + topic.clientHeight / 4 < current ? index : acc
    }, 0)

    var activeColor = !topics[0] ? 'fff' : topics[activeElement].dataset.color

    animations.forEach(function(animation, index) {
      animation.style.opacity = index === activeElement ? 1 : 0;
    })

    animationWrapper.style.backgroundColor = activeColor
  })
}



var animations = []
var animationData = null

fetch('/animation/animations.json')
  .then(function(res) {
    if (res.ok) return res.json()
  })
  .then(function(json) {
    animationData = json
  })


function playAnimation(data) {
  if (!animationData) return false

  console.log('playing animation: ', data)

  var name = data[1]
  var id = data[0]

  window.requestAnimationFrame(function() {
    if (animations[id]) {
      animations[id].play()
      return
    }

    animations[id] = bodymovin.loadAnimation({
      container: document.getElementById(id),
      animationData: animationData[name] || animationData['vd'],
      renderer: 'svg',
      loop: true,
      autoplay: true,
    })
  })
}

app.ports.playAnimation.subscribe(playAnimation)

app.ports.stopAnimation.subscribe(function(id) {
  if (animations[id]) {
    animations[id].pause()
  }
})


app.ports.playIntroAnimation.subscribe(function() {
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

