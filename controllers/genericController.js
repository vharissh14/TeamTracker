var express = require('express');
var router = express.Router();
var request = require('request');
var config = require('config.json');

router.post('/share', function (req, res) {
    request.post({
        url: config.apiUrl + '/share/userShare',
        form: req.body,
        json: true
    }, function (error, response, body) {
        if (error) {
            return res.render('register', { error: 'An error occurred' });
        }
    });
});



module.exports = router;
