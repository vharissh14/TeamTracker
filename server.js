require('rootpath')();
var express = require('express');
// var redis = require("redis");
// var subscriber = redis.createClient(6379,'192.168.1.5');
// var publisher = redis.createClient(6379,'192.168.1.5');
//anil-test
//new -test
//new one
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
app.use('/api', expressJwt({ secret: config.secret }).unless({ path: ['/api/users/authenticate', '/api/users/register','/api/users/teamDetails','/api/users/team','/api/users/team1'] }));

// routes
app.use('/login', require('./controllers/login.controller'));
app.use('/register', require('./controllers/register.controller'));
app.use('/app', require('./controllers/app.controller'));
app.use('/api/users', require('./controllers/api/users.controller'));

// make '/app' default route
app.get('/', function (req, res) {
    return res.redirect('/app');
});

var userData={};
var flag=0;
var rooms=[];
io.sockets.on('connection', function(socket){
    socket.on('subscribe', function(data) { 
        socket.join(data.mission); 
        
        for (var i=0;i<rooms.length;i++){
            flag=0;
            if(data.mission==rooms[i]){
                flag=1;   
            }
        }
        var users=[];
        if(flag!=0){
            console.log("in")
            var oldData = userData[data.mission]
            users.push(oldData)
           //??????????
           var updateflag=0;
           for (var i = 0; i < users.length; i++) {
            if(users[i].nickname==data.nickname){
                users[i].lat=data.lat;
                updateflag=1;
                break;
            }
           }
           if(updateflag==0){
            users.push(data);
           }  
           userData[data.mission]=users
        }
        if(flag==0){
            rooms.push(data.mission);
            userData[data.mission]=data;
            users.push(data);
            flag=1;
        }
        console.log("users :"+JSON.stringify(users))
         io.sockets.to(data.mission).emit('userList', users);
    })
});
// start server
http.listen(3000, function () {
    console.log('Server Listening to http://' + http.address().address + ':' + http.address().port);
});
