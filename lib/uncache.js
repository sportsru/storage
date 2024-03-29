// Generated by CoffeeScript 1.6.1
var EXPIRES_TIME, app, exports, memcached;

memcached = require('./memcached');

app = require('./app');

EXPIRES_TIME = 2 * 24 * 60 * 60;

exports = module.exports = function(uid, version, callback) {
  var data, key1;
  key1 = "" + app.settings.memcachedPrefix + uid;
  data = {
    version: version
  };
  return memcached.set(key1, data, EXPIRES_TIME, function(err, result) {
    return memcached.gets(key1, function(err, result) {
      if (err) {
        return callback(503);
      } else {
        return memcached.cas(key1, data, result.cas, 0, function(err, result) {
          if (err) {
            return callback(503);
          } else {
            return callback(200);
          }
        });
      }
    });
  });
  /*memcached.set(key2, data, EXPIRES_TIME, (err, result) ->
  		memcached.gets key2, (err, result) ->
  			if err
  				callback(503)
  			else
  				memcached.cas key2, data, result.cas, 0, (err, result) ->
  					if err
  						callback 503
  					else
  						callback 200
  	)
  */

};
