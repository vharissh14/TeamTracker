require('rootpath')();

var express = require('express');
// var redis = require("redis");
// var subscriber = redis.createClient(6379,'192.168.1.5');
// var publisher = redis.createClient(6379,'192.168.1.5');
var app = express();
var http = require('http').Server(app);
var io = require('socket.io')(http);
var session = require('express-session');
var bodyParser = require('body-parser');
var expressJwt = require('express-jwt');
var config = require('config.json');
app.set('view engine', 'ejs');
app.set('views', __dirname + '/views');
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
app.use(session({ secret: config.secret, resave: false, saveUninitialized: true }));

// use JWT auth to secure the api
app.use('/api', expressJwt({ secret: config.secret }).unless({ path: ['/api/users/authenticate', '/api/users/register'] }));

// routes
app.use('/login', require('./controllers/login.controller'));
app.use('/register', require('./controllers/register.controller'));
app.use('/app', require('./controllers/app.controller'));
app.use('/api/users', require('./controllers/api/users.controller'));

// make '/app' default route
app.get('/', function (req, res) {
    return res.redirect('/app');
});

var userList = [];
io.sockets.on('connection', function(clientSocket){
    clientSocket.on("connectUser", function(data) {
        var message = "User " + data.nickname + " was connected.";
        console.log(message);
        var userInfo={};
        var foundUser = false;
        for (var i=0; i<userList.length; i++) {
          if (userList[i]["nickname"] == data.nickname) {
            userList[i]["isConnected"] = true
            userList[i]["id"] = clientSocket.id;
            userInfo = userList[i];
            foundUser = true;
            break;
          }
        }
        if (!foundUser) {
          userInfo["id"] = clientSocket.id;
          userInfo["nickname"] = data.nickname;
          userInfo["isConnected"] = true;
          userInfo["lat"]=data.lat;
          userInfo["phone"]=data.phone;
          userInfo["email"]=data.email;
          userInfo["team"]=data.team;
          userList.push(userInfo);
        }
        // console.log("list :"+data)
        // publisher.publish("example", data);
        // subscriber.on("message", function(channel, message) {
        //     console.log("Message '" + message + "' on channel '" + channel + "' arrived!")
        //   });
        //   subscriber.subscribe("examplerep");
        io.emit("userList", userList);
    });
});
// start server
http.listen(3000, function () {
    console.log('Server listening to http://' + http.address().address + ':' + http.address().port);
});
