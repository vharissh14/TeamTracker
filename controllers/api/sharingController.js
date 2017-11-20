var config = require('config.json');
var express = require('express');
var router = express.Router();
var userService = require('services/user.service');

// routes
router.post('/userShare', userShare);

module.exports = router;

function userShare(req, res) {
  // console.log("reg :"+JSON.stringify(req.body))
  shareService.share(req.body)
  .then(function () {
    res.sendStatus(200);
  })
  .catch(function (err) {
    res.status(400).send(err);
  });
}




