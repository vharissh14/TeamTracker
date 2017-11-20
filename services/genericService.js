var config = require('config.json');
var _ = require('lodash');
var jwt = require('jsonwebtoken');
var bcrypt = require('bcryptjs');
var Q = require('q');
var genericService = require('services/genericService');
var service = {};

service.userShare = userShare;

function userShare(shareParam) {
  var deferred = Q.defer();
  genericService.db.share.insert(
    shareParam,
    function (err, doc) {
      if (err) deferred.reject(err.name + ': ' + err.message);

      deferred.resolve();
    });

  return deferred.promise;
}

