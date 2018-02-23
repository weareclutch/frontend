'use strict';

var Elm = require('./Main.elm');
var mountNode = document.getElementById('elm-app');

var app = Elm.Main.embed(mountNode);


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

app.ports.scrollHomePageDown.subscribe(function() {
  window.requestAnimationFrame(function() {
    var home = document.querySelector('.page-wrapper.home')
    home.scrollTop = home.scrollHeight
  })
})

var ticking = false
var lastKnownY = 0

function update() {
  ticking = false
  app.ports.setScrollPosition.send(lastKnownY)
}

function requestTick() {
  if (!ticking) {
    window.requestAnimationFrame(update)
  }
  ticking = true
}

function onScroll(e) {
  lastKnownY = e.target.scrollTop
  requestTick()
}

setTimeout(function() {
  var pageWrappers = document.querySelectorAll('.page-wrapper')
  var caseWrappers = document.querySelectorAll('.overlay')

  pageWrappers.forEach(function(wrapper, index) {
    wrapper.addEventListener('scroll', onScroll)
  })

  caseWrappers.forEach(function(wrapper, index) {
    wrapper.addEventListener('scroll', onScroll)
  })
}, 2000)
