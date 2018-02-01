'use strict';

function debounce(func, wait, immediate) {
  var timeout;
  return function() {
    var context = this, args = arguments;
    var later = function() {
      timeout = null
      if (!immediate) func.apply(context, args)
    }
    var callNow = immediate && !timeout
    clearTimeout(timeout)
    timeout = setTimeout(later, wait)
    if (callNow) func.apply(context, args)
  }
}

var Elm = require('./Main.elm');
var mountNode = document.getElementById('elm-app');

var app = Elm.Main.embed(mountNode);


app.ports.getCasePosition.subscribe(function(id) {
  var homeNode = document
    .querySelector('.home')
 
  if (!homeNode) {
    return null
  }

  var caseNode = homeNode.querySelector('.case-' + id)


  if (caseNode) {
    var pos = caseNode.getBoundingClientRect()
    app.ports.newCasePosition.send(pos)
  }
})


var offset = 100
setTimeout(function() {
  var pageWrappers = document.querySelectorAll('.page-wrapper')

  pageWrappers.forEach(function(wrapper, index) {
    var debounced = debounce(function() {
      if (wrapper.className.indexOf('active') === -1) return false

      if (wrapper.scrollTop < offset) {
        return app.ports.changeMenu.send('top')

      } else if ((wrapper.scrollTop + window.innerHeight) > (wrapper.scrollHeight - offset)) {
        return app.ports.changeMenu.send('bottom')

      }

      return app.ports.changeMenu.send('close')
    }, 20)
    
    wrapper.addEventListener('scroll', debounced)
  })
}, 2000)


