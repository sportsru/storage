memcached = require './memcached'
app = require './app'

module.exports = (uid, version, callback) -> 
	key = "#{app.settings.memcachedPrefix}#{uid}"
	data =
		version: version

	memcached.set key, data, 0, (err, result) ->
		memcached.gets key, (err, result) ->
			if err
				callback 503
			else
				memcached.cas key, data, result.cas, 0, (err, result) ->
					if err
						callback 503
					else
						callback 200