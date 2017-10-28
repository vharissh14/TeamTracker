var express = require('express');
var router = express.Router();


router.use('/', function (req, res, next) {
    if (req.path !== '/login' && !req.session.token) {
        return res.redirect('/login?returnUrl=' + encodeURIComponent('/app' + req.path));
    }
 
    next();
});
// make JWT token available to angular app
router.get('/token', function (req, res) {
    res.send(req.session);
});

// serve angular app files from the '/app' route
router.use('/', express.static('app'));

module.exports = router;
