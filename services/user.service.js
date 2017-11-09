var config = require('config.json');
var _ = require('lodash');
var jwt = require('jsonwebtoken');
var bcrypt = require('bcryptjs');
var Q = require('q');
var mongo = require('mongoskin');
var db = mongo.db(config.connectionString, { native_parser: true });
db.bind('users');
db.bind('team');
db.bind('session');


var service = {};

service.authenticate = authenticate;
service.getById = getById;
service.get = get;

service.create = create;
service.teamDetails = teamDetails;
service.delete = _delete;
module.exports = service;

function authenticate(pseudoName, password, mission) {
  var deferred = Q.defer();
  db.users.findOne({ pseudoName: pseudoName }, function (err, user) {
    if (err) deferred.reject(err.name + ': ' + err.message);
    if (user && bcrypt.compareSync(password, user.hash)) {
      // authentication successful
      createUserSession();
      var userObj = {};
      userObj.pseudoName = pseudoName;
      userObj.mission = mission;
      userObj.token = jwt.sign({ sub: user._id }, config.secret)
      deferred.resolve(userObj);
    } else {
      // authentication failed
      deferred.resolve();
    }
  });
  function createUserSession() {
    var user = {};
    user.pseudoName = pseudoName;
    user.mission = mission;
    db.session.insert(
      user,
      function (err, doc) {
        if (err) deferred.reject(err.name + ': ' + err.message);
        deferred.resolve();
      });
  }
  return deferred.promise;
}

function getById(_id) {
  var deferred = Q.defer();
  db.users.findById(_id, function (err, user) {
    if (err) deferred.reject(err.name + ': ' + err.message);

    if (user) {
      // return user (without hashed password)
      deferred.resolve(_.omit(user, 'hash'));
    } else {
      // user not found
      deferred.resolve();
    }
  });

  return deferred.promise;
}

function get() {
  var deferred = Q.defer();
  db.collection("team").find({}).toArray(function(err,user) {
    if (err) throw err;
    if (err) deferred.reject(err.name + ': ' + err.message);
        if (user) {
          // return user (without hashed password)
          deferred.resolve(user);
        } else {
          // user not found
          deferred.resolve();
        }
  });
  return deferred.promise;
}

function create(userParam) {
  var deferred = Q.defer();

  // validation
  db.users.findOne(
    { pseudoName: userParam.pseudoName },
    function (err, user) {
      if (err) deferred.reject(err.name + ': ' + err.message);

      if (user) {
        // pseudoName already exists
        deferred.reject('pseudoName "' + userParam.pseudoName + '" is already taken');
      } else {
        createUser();
      }
    });

  function createUser() {
    // set user object to userParam without the cleartext password

    var user = _.omit(userParam, 'password');
    // add hashed password to user object
    user.hash = bcrypt.hashSync(userParam.password, 10);

    db.users.insert(
      user,
      function (err, doc) {
        if (err) deferred.reject(err.name + ': ' + err.message);

        deferred.resolve();
      });
  }

  return deferred.promise;
}
function teamDetails(userParam) {
  var deferred = Q.defer();
  db.team.insert(
    userParam,
    function (err, doc) {
      if (err) deferred.reject(err.name + ': ' + err.message);

      deferred.resolve();
    });

  return deferred.promise;
}
function _delete(pseudoName) {
  var deferred = Q.defer();
  db.session.remove(
    { pseudoName: mongo.helper.toObjectID(pseudoName) },
    function (err) {
      if (err) deferred.reject(err);

      deferred.resolve();
    });

  return deferred.promise;
}


// var userData={};
// var flag=0;
// var rooms=[];
// io.sockets.on('connection', function(socket){
//     socket.on('subscribe', function(data) { 
//         socket.join(data.mission); 
        
//         for (var i=0;i<rooms.length;i++){
//             flag=0;
//             if(data.mission==rooms[i]){
//                 flag=1;   
//             }
//         }

//         var users=[];
//         if(flag!=0){
//             console.log("in")
//             var oldData = userData[data.mission]
//             users.push(oldData)
//             users.push(data);
//             userData[data.mission]=users  
//         }
//         if(flag==0){
//             rooms.push(data.mission);
//             userData[data.mission]=data;
//             users.push(data);
//             flag=1;
//         }
        
        
//         console.log("users :"+JSON.stringify(users))

//          io.sockets.to(data.mission).emit('userList', users);
//     })
// });