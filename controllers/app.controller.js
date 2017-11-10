var express = require('express');
var router = express.Router();


router.use('/', function (req, res, next) {
    if (req.path !== '/login' && !req.session.token) {
        return res.redirect('/login?');
    }
 
    next();
});
router.use('/', express.static('app'));
// make JWT token available to angular app
router.get('/token', function (req, res) {
    res.send(req.session);
});

// serve angular app files from the '/app' route

module.exports = router;
