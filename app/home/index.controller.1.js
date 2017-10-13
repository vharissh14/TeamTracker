(function () {
  'use strict';
  angular.module('app').controller('homeController',['$scope','UserService','$window',function($scope,UserService,$window){
    var userObj;
    initController();
    function initController() {
      UserService.GetCurrent().then(function (user) {
        $scope.user = user;
        userObj=user;
      });
    }
    $scope.users=[];
    navigator.geolocation.getCurrentPosition(function(pos){
      $window.map = map;
      // alert("lat"+pos.coords.latitude);
      // alert("long"+pos.coords.longitude);
      var myLatLng  =new google.maps.LatLng(pos.coords.latitude, pos.coords.longitude);
      var map = new google.maps.Map(document.getElementById('map'), {
        zoom: 15,
        center: myLatLng
      });
      var marker = new google.maps.Marker({
        position: myLatLng,
        map: map,
        title: 'User Information'
      });
      marker.addListener('click', function() {
        infowindow.open(map, marker);
      });
      var userInfo = '<div class="panel panel-info">'+
      '<div class="panel-heading">'+
      '<h3 class="panel-title">User Information</h3>'+
      '</div>'+
      '<div class="panel-body">'+
      '<div class="row">'+
      '<table class="table table-user-information">'+
      '<tbody>'+
      '<tr>'+
      '<td>Name</td>'+
      '<td>'+userObj.name+'</td>'+
      '</tr>'+
      '<tr>'+
      '<td>Phone Number:</td>'+
      '<td>'+userObj.phone+'</td>'+
      '</tr>'+
      '<tr>'+
      '<td>Email</td>'+
      '<td>'+userObj.email+'</td>'+
      '</tr>'+
      '<tr>'+
      '<td>TeamName</td>'+
      '<td>'+userObj.teamName+'</td>'+
      '</tr>'+
      '</tbody>'+
      '</table>'+
      '</div>'+
      '</div>'+
      '</div>';

      var infowindow = new google.maps.InfoWindow({
        content: userInfo
      });
      $(function () {
        var socket = io();
          socket.emit('connectUser', {nickname:userObj.name,lat:myLatLng});
        socket.on('userList', function(userList){
          $('#messages').text('');
          for (var i=0; i<userList.length; i++) {
            // $scope.users=userList[i]
            $('#messages').append($('<li>').text(userList[i].nickname));

          }


          
        });
      });
      
    })

  }]);

})();
