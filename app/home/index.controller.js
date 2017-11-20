(function () {
  'use strict';
  angular.module('app').controller('homeController', ['$scope', 'UserService', '$window', function ($scope, UserService, $window) {
    var room;
    var myLatLng;
    var users;
    var marker = {};
    var markers = [];
    var currentUser;
    getMission()
    getCurrentUser();
    var socket = io.connect();
    function getMission() {
      UserService.GetCurrentMission().then(function (mission) {
        room = mission.mission;
      });
    }
    function getCurrentUser() {
    //   function hasUserMedia() { 
    //     //check if the browser supports the WebRTC 
    //     return !!(navigator.getUserMedia || navigator.webkitGetUserMedia || 
    //        navigator.mozGetUserMedia); 
    //  } 
     
    //  if (hasUserMedia()) { 
    //     navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia
    //        || navigator.mozGetUserMedia; 
         
    //     //enabling video and audio channels 
    //     navigator.getUserMedia({ video: true, audio: true }, function (stream) { 
    //        var video = document.querySelector('video'); 
         
    //        //inserting our stream to the video tag     
    //        video.src = window.URL.createObjectURL(stream); 
    //     }, function (err) {}); 
    //  } else { 
    //     alert("WebRTC is not supported"); 
    //  }




     
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(function (pos) {
          myLatLng = new google.maps.LatLng(pos.coords.latitude, pos.coords.longitude);
          $window.map = map;
          var map = new google.maps.Map(document.getElementById('map'), {
            zoom: 15,
            center: myLatLng
          });
          UserService.GetCurrent().then(function (user) {
            $scope.user = user;
            currentUser = user
            user.lat = myLatLng;
            user.mission = room;
            socket.emit('subscribe', user);
            setInterval(getNewCords, 1000);
          });
          var infowindow = new google.maps.InfoWindow();

          socket.on('userList', function (userList) {
            for (var i = 0; i < markers.length; i++) {
              markers[i].setMap(null);
            }
            users = userList;
            for (var i = 0; i < userList.length; i++) {
              var image;
              if(userList[i].teamIcon.includes("http")){
                 image=userList[i].teamIcon;
              }else{
                 image="http://www.freeiconspng.com/uploads/profile-icon-9.png"
              }
              var image = {
                url:image,
                scaledSize: new google.maps.Size(52, 52),
              };
              marker[userList[i].pseudoName] = new google.maps.Marker({
                position: new google.maps.LatLng(userList[i].lat.lat, userList[i].lat.lng),
                map: map,
                icon: image
              });
              markers.push(marker[userList[i].pseudoName]);
              var newMarker = marker[userList[i].pseudoName];
              google.maps.event.addListener(newMarker, 'click', (function (newMarker, i) {
                return function () {
                  infowindow.setContent('<div class="panel panel-info">' +
                    '<div class="panel-heading">' +
                    '<h3 class="panel-title">User Information</h3>' +
                    '</div>' +
                    '<div class="panel-body">' +
                    '<div class="row">' +
                    '<table class="table table-user-information">' +
                    '<tbody>' +
                    '<tr>' +
                    '<td>Name</td>' +
                    '<td>' + userList[i].pseudoName + '</td>' +
                    '</tr>' +
                    '<tr>' +
                    '<td>Phone Number:</td>' +
                    '<td>' + userList[i].phone + '</td>' +
                    '</tr>' +
                    '<tr>' +
                    '<td>Email</td>' +
                    '<td>' + userList[i].email + '</td>' +
                    '</tr>' +
                    '<tr>' +
                    '<td>TeamName</td>' +
                    '<td>' + userList[i].teams + '</td>' +
                    '</tr>' +
                    '</tbody>' +
                    '</table>' +                    
                    '</div>' +
                    '</div>' +
                    '</div>'
                  );
                  infowindow.open(map, newMarker);
                }
              })(newMarker, i));
            }


          });

        })

      } else {
        alert('Geo Location feature is not supported in this browser.');
      }

    }
    var watchID;
    function getNewCords() {
      function showLocation(position) {
        var latitude = position.coords.latitude;
        var longitude = position.coords.longitude;
        var myLatLng={};
        myLatLng.lat=latitude;
        myLatLng.lng=longitude;
        var userObj = {}
        userObj.lat = myLatLng;
        userObj.pseudoName = currentUser.pseudoName
        socket.emit('locationChanged', userObj);
        socket.on('locationUpdate', function (user) {
          console.log(angular.toJson(user))
          var position = new google.maps.LatLng(user.lat.lat, user.lat.lng);
          marker[user.pseudoName].setPosition(position);
        });
     }
     
        if(navigator.geolocation){
           watchID = navigator.geolocation.watchPosition(showLocation);
       }
       
    }


  }]);

})();
