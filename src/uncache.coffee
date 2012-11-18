# Необходимые модули

memcached = require './memcached'

#

app = require('./app')

EXPIRES_TIME = 2 * 24 * 60 * 60

exports = module.exports = (uid, version, callback) ->
	#if uid.substr(uid.length - 2, 2) == '=='
	#	uidtest = uid.substr(0,uid.length-2)

	key1 = "#{app.settings.memcachedPrefix}#{uid}"
	#key2 = "#{app.settings.memcachedPrefix}#{uidtest}"
	
	data = version: version

	memcached.set(key1, data, EXPIRES_TIME, (err, result) ->
		memcached.gets key1, (err, result) ->
			if err
				callback(503)
			else
				memcached.cas key1, data, result.cas, 0, (err, result) ->
					if err
						callback 503
					else
						callback 200
	)
	
	###memcached.set(key2, data, EXPIRES_TIME, (err, result) ->
		memcached.gets key2, (err, result) ->
			if err
				callback(503)
			else
				memcached.cas key2, data, result.cas, 0, (err, result) ->
					if err
						callback 503
					else
						callback 200
	)###