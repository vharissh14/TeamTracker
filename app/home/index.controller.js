(function () {
  'use strict';
  angular.module('app').controller('homeController',['$scope','UserService','$window',function($scope,UserService,$window){
    var userObj;
    var room;
    
    initController();
    getMission()
    function initController() {
      UserService.GetCurrent().then(function (user) {
        $scope.user = user;
        userObj=user;
      });
    }
    function getMission() {
      UserService.GetCurrentMission().then(function (mission) {
        room=mission.missionField;
        console.log("ss :"+angular.toJson(mission))
      });
    }
    navigator.geolocation.getCurrentPosition(function(pos){
      var myLatLng  =new google.maps.LatLng(pos.coords.latitude, pos.coords.longitude);
      $window.map = map;      
    var map = new google.maps.Map(document.getElementById('map'), {
        zoom: 15,
        center: myLatLng
    });
    var infowindow = new google.maps.InfoWindow();
    var socket = io.connect();
//         setInterval(getNewCords, 2000);
//         function getNewCords(){
//           navigator.geolocation.getCurrentPosition(function(position) {
//       var myLatLng  =new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
//       socket.emit('subscribe',{nickname:userObj.name,lat:myLatLng,phone:userObj.phone,email:userObj.email,team:userObj.team,icon:userObj.icon,mission:room}) ;     ;
// // socket.emit('connectUser', {nickname:userObj.name,lat:myLatLng,phone:userObj.phone,email:userObj.email,team:userObj.team,icon:userObj.icon});
//           });
//         }
      socket.emit('subscribe',{nickname:userObj.name,lat:myLatLng,phone:userObj.phone,email:userObj.email,team:userObj.team,icon:userObj.icon,mission:room}) ;     ;
      
        socket.on('userList', function(userList){
          $('#messages').text('');
          for (var i = 0; i < userList.length; i++) {
            console.log("icon:"+angular.toJson(userList[i]))
            var image = {
              url: userList[i].icon,
              scaledSize : new google.maps.Size(34, 32),
          };
            // $('#messages').append($('<li>').text(userList[i].nickname));
                    var newMarker = new google.maps.Marker({
                        position: new google.maps.LatLng(userList[i].lat.lat, userList[i].lat.lng),
                        map: map,
                        icon:image
                    });

                    google.maps.event.addListener(newMarker, 'click', (function (newMarker, i) {
                      return function () {
                          infowindow.setContent('<div class="panel panel-info">'+
                          '<div class="panel-heading">'+
                          '<h3 class="panel-title">User Information</h3>'+
                          '</div>'+
                          '<div class="panel-body">'+
                          '<div class="row">'+
                          '<table class="table table-user-information">'+
                          '<tbody>'+
                          '<tr>'+
                          '<td>Name</td>'+
                          '<td>'+userList[i].nickname+'</td>'+
                          '</tr>'+
                          '<tr>'+
                          '<td>Phone Number:</td>'+
                          '<td>'+userList[i].phone+'</td>'+
                          '</tr>'+
                          '<tr>'+
                          '<td>Email</td>'+
                          '<td>'+userList[i].email+'</td>'+
                          '</tr>'+
                          '<tr>'+
                          '<td>TeamName</td>'+
                          '<td>'+userList[i].team+'</td>'+
                          '</tr>'+
                          '</tbody>'+
                          '</table>'+
                          '</div>'+
                          '</div>'+
                          '</div>'
                        );
                          infowindow.open(map, newMarker);
                      }
                  })(newMarker, i));
                }

      });
      //   socket.on('userList', function(userList){
      //     console.log(userList.length)
      //     $('#messages').text('');           
      //     angular.forEach(userList, function (value) {
      //       console.log("ss :"+angular.toJson(value.nickname))
      //      $('#messages').append($('<li>').text(value.nickname));                      
      //   });
      //     // for (var i = 0; i < userList.length; i++) {
      //     //   console.log("icon:"+userList[i])
      //     // };
      //     // console.log("list :"+angular.toJson(userList));
      //     // $('#messages').append($('<li>').text(userList.nickname));                      
          

      // });
      
    })

  }]);

})();
