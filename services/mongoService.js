var config = require('config.json');
var mongo = require('mongoskin');
var db = mongo.db(config.connectionString, { native_parser: true });
db.bind(config.db.user);
db.bind(config.db.team);
db.bind(config.db.session);

var mongoService = {};
mongoService.db = db;
module.exports = mongoService;

