var config = require('config.json');
var express = require('express');
var router = express.Router();
var userService = require('services/user.service');

// routes
router.post('/authenticate', authenticateUser);
router.post('/register', registerUser);
router.get('/current', getCurrentUser);
module.exports = router;

function authenticateUser(req, res) {
  userService.authenticate(req.body.username, req.body.password,req.body.missionField)
  .then(function (token) {
    if (token) {
      // authentication successful
      res.send(token);
    } else {
      // authentication failed
      res.status(401).send('Username or password is incorrect');
    }
  })
  .catch(function (err) {
    res.status(400).send(err);
  });
}

function registerUser(req, res) {
  // console.log("reg :"+JSON.stringify(req.body))
  userService.create(req.body)
  .then(function () {
    res.sendStatus(200);
  })
  .catch(function (err) {
    res.status(400).send(err);
  });
}

function getCurrentUser(req, res) {
  console.log(req.user.sub)
  userService.getById(req.user.sub)
  .then(function (user) {
    if (user) {
      res.send(user);
    } else {
      res.sendStatus(404);
    }
  })
  .catch(function (err) {
    res.status(400).send(err);
  });
}
