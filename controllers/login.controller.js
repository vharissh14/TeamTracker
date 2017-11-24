var express = require('express');
var router = express.Router();
var request = require('request');
var config = require('config.json');
var userService = require('services/user.service');


router.get('/', function (req, res) {
  delete req.session.token;
  // move success message into local variable so it only appears once (single read)
  var viewData = { success: req.session.success };
  delete req.session.success;

  res.render('login');
  // if(req.session.pseudoName){
  //   userService.delete(req.session.pseudoName)
  //   .then(function () {
  //     res.sendStatus(200);
  //   })
  //   .catch(function (err) {
  //     res.status(400).send(err);
  //   });
  // }
});

router.post('/', function (req, res) {
  // authenticate using api to maintain clean separation between layers
  request.post({
    url: config.apiUrl + '/users/authenticate',
    form: req.body,
    json: true
  }, function (error, response, body) {
    if (error) {
      return res.render('login', { error: 'An error occurred' });
    }
    if (!body.token) {
      return res.render('login', { error: body, pseudoName: req.body.pseudoName });
    }
    // save JWT token in the session to make it available to the angular app
    req.session.token = body.token;
    req.session.pseudoName = body.pseudoName;
    req.session.mission = body.mission;
    // redirect to returnUrl
    var returnUrl='/';
    // var returnUrl = req.query.returnUrl && decodeURIComponent(req.query.returnUrl) || '/';
    res.redirect(returnUrl);
  });
});

module.exports = router;
