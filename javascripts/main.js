require('coffee-script');
require('./javascripts/awesomebox_ui');

window.App = global.App = new global.AwesomeboxUI();
$(function() {
  App.start();
});
