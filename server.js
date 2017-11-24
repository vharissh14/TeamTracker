require('rootpath')();
var express = require('express');
 var redis = require("redis");
//  var subscriber = redis.createClient(6379,'redis');
//  var publisher = redis.createClient(6379,'redis');
var app = express();
var http = require('http').Server(app);
var io = require('socket.io')(http);
var session = require('express-session');
var MongoDBStore = require('connect-mongodb-session')(session);
var bodyParser = require('body-parser');
var expressJwt = require('express-jwt');
var config = require('config.json');
app.set('view engine', 'ejs');
app.set('views', __dirname + '/views');
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

var store = new MongoDBStore(
    {
      uri: config.connectionString,
      collection: config.db.session
    });
  store.on('error', function(error) {
    assert.ifError(error);
    assert.ok(false);
  });
  app.use(session({
    secret: config.secret,
    store: store,
    resave: true,
    saveUninitialized: true
  }));

// use JWT auth to secure the api
app.use('/api', expressJwt({ secret: config.secret }).unless({ path: ['/api/users/authenticate', '/api/users/register', '/api/users/teamDetails', '/api/users/team', '/api/users/team1'] }));

// routes
app.use('/login', require('./controllers/login.controller'));
app.use('/register', require('./controllers/register.controller'));
app.use('/app', require('./controllers/app.controller'));
app.use('/api/users', require('./controllers/api/users.controller'));
app.use('/api/share', require('./controllers/api/sharingController'));
app.use('/generic', require('./controllers/genericController'));


// make '/app' default route
app.get('/', function (req, res) {
    return res.redirect('/app');
});



var userList = [];
io.sockets.on('connection', function (socket) {
    var room;
    socket.on('subscribe', function (data) {
        room = data.mission;
        // console.log("room"+JSON.stringify(data.mission))
        socket.join(data.mission);
        var foundUser = false;
        for (var i = 0; i < userList.length; i++) {
            if (userList[i]["pseudoName"] == data.pseudoName) {
                userList[i]["id"] = socket.id;
                foundUser = true;
                break;
            }
        }
        var roomUsers = [];
        if (!foundUser) {
            socket.user = data;
            userList.push(data);
        }
        for (var i = 0; i < userList.length; i++) {
            if (userList[i].mission == data.mission) {
                roomUsers.push(userList[i])
            }
        }
        console.log("data :"+JSON.stringify(roomUsers))
        // publisher.publish("example", roomUsers);
        // subscriber.on("message", function(channel, message) {
        //     console.log("Message '" + message + "' on channel '" + channel + "' arrived!")
        //   });
        //   subscriber.subscribe("examplerep");
        console.log("users :" + JSON.stringify(roomUsers))
        io.sockets.to(data.mission).emit('userList', roomUsers);
    })
    socket.on('disconnect', function () {
        console.log('user disconnected');
        console.log("disconnect :" + JSON.stringify(socket.user))

        var index = userList.indexOf(socket.user);
        userList.splice(index, 1);
        var rooms = [];
        for (var i = 0; i < userList.length; i++) {
            if (userList[i].mission == room) {
                rooms.push(userList[i])
            }
        }
        console.log("out :" + JSON.stringify(rooms))
        io.sockets.to(room).emit('userList', rooms);

    });

    socket.on('locationChanged', function (data) {
        io.sockets.emit('locationUpdate', data);
    })

});

// start server
http.listen(3000, function () {
    console.log('Server Listening to http://' + http.address().address + ':' + http.address().port);
});
