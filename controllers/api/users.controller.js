var config = require('config.json');
var express = require('express');
var router = express.Router();
var userService = require('services/user.service');

// routes
router.post('/authenticate', authenticateUser);
router.post('/register', registerUser);
router.post('/teamDetails', teamDetails);

router.get('/current', getCurrentUser);
router.get('/team', teamInfo);

module.exports = router;

function authenticateUser(req, res) {
  userService.authenticate(req.body.pseudoName, req.body.password,req.body.mission)
  .then(function (token) {
    if (token) {
      // authentication successful
      res.send(token);
    } else {
      // authentication failed
      res.status(401).send('pseudoName or password is incorrect');
    }
  })
  .catch(function (err) {
    res.status(400).send(err);
  });
}

function registerUser(req, res) {
  // console.log("reg :"+JSON.stringify(req.body))
  userService.create(req.body)
  .then(function (usr) {
    res.sendStatus(200);
  })
  .catch(function (err) {
    res.status(400).send(err);
  });
}

function teamDetails(req, res) {
  userService.teamDetails(req.body)
  .then(function () {
    res.sendStatus(200);
  })
  .catch(function (err) {
    res.status(400).send(err);
  });
}

function getCurrentUser(req, res) {
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

function teamInfo(req, res) {
  //  res.send("hi123")
 userService.get()
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