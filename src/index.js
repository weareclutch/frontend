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
        playAnimation([animation.id, animationNames[index]], 0, true)
      })
    }

    page.parentElement.addEventListener('scroll', aboutUsHandleScroll)
  })
})


app.ports.bindServicesPage.subscribe(function(data) {
  window.requestAnimationFrame(function() {
    data.forEach(function(animation, index) {
      setupAnimation(['expertise-animation-' + index, animation])
    })
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

    // set burger animation
    setupAnimation(['burger-animation', 'burger'])
  })


app.ports.setupNavigation.subscribe(function() {
  window.requestAnimationFrame(function() {
    setupAnimation(['burger-animation', 'burger'])
  })
})


var lastBurgerAnimation = null
app.ports.changeMenuState.subscribe(function(state) {
  if (!animations['burger-animation']
      || lastBurgerAnimation === state) {
    return false
  }

  lastBurgerAnimation = state

  if (state === 'BURGERCROSS') {
    animations['burger-animation'].playSegments([[0, 120]]) // burger -> cross
    window.setTimeout(function() { stopAnimation('burger-animation', 120) }, 700)
  } else if (state === 'CROSSBURGER') {
    animations['burger-animation'].playSegments([[120, 240]]) // cross -> burger
    window.setTimeout(function() { stopAnimation('burger-animation', 120) }, 700)
  } else if (state === 'BURGERARROW') {
    animations['burger-animation'].playSegments([[240, 340]]) // cross -> burger
    window.setTimeout(function() { stopAnimation('burger-animation', 100) }, 1200)
  } else if (state === 'ARROWBURGER') {
    animations['burger-animation'].playSegments([[410, 490]]) // cross -> burger
    window.setTimeout(function() { stopAnimation('burger-animation', 140) }, 600)
  }
})


function setupAnimation(data, autoplay) {
  if (!animationData) return false

  window.requestAnimationFrame(function() {
    var name = data[1]
    var id = data[0]

    var element = document.getElementById(id)
    if (!element) return false

    animations[id] = bodymovin.loadAnimation({
      container: element,
      animationData: animationData[name] || animationData['vd'],
      renderer: 'svg',
      loop: true,
      autoplay: !!autoplay,
    })
  })
}


function playAnimation(data, position, autoplay) {
  if (!animationData) return false

  var name = data[1]
  var id = data[0]

  window.requestAnimationFrame(function() {
    if (!animations[id]) {
      return setupAnimation(data, autoplay)
    }

    return position !== undefined ?
      animations[id].goToAndPlay(position, true) :
      animations[id].play()
  })
}
app.ports.playAnimation.subscribe(playAnimation)


function stopAnimation(id, position) {
  if (!animations[id]) return false

  return position !== undefined ?
    animations[id].goToAndStop(position, true) :
    animations[id].pause()
}
app.ports.stopAnimation.subscribe(stopAnimation)


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

