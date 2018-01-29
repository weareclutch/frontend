'use strict';

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
