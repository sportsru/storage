memcached = require './memcached'
app = require './app'

module.exports = (uid, version, callback) -> 
	key1 = "#{app.settings.memcachedPrefix}#{uid}"
	memuid = escape uid
	key2 = "#{app.settings.memcachedPrefix}#{memuid}"
	data =
		version: version

	memcached.set key1, data, 0, (err, result) ->
		memcached.gets key1, (err, result) ->
			if err
				callback 503
			else
				memcached.cas key1, data, result.cas, 0, (err, result) ->
					if err
						callback 503
					else
						callback 200
	
	memcached.set key2, data, 0, (err, result) ->
		memcached.gets key2, (err, result) ->
			if err
				callback 503
			else
				memcached.cas key2, data, result.cas, 0, (err, result) ->
					if err
						callback 503
					else
						callback 200