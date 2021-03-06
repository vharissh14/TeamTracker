(function () {
  'use strict';
  angular.module('app').factory('UserService', Service);

  function Service($http, $q) {
    var service = {};
    service.GetCurrent = GetCurrent;
    service.GetCurrentMission = GetCurrentMission;
    
    return service;

    function GetCurrent() {
      return $http.get('/api/users/current').then(handleSuccess, handleError);
    }
    function GetCurrentMission() {
      return $http.get('/app/token').then(handleSuccess, handleError);
    }
    function GetCurrentMission() {
      return $http.get('/app/token').then(handleSuccess, handleError);
    }
    function handleSuccess(res) {
      return res.data;
    }

    function handleError(res) {
      return $q.reject(res.data);
    }
  }

})();
