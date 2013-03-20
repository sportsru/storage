# Обработчики запросов
#
# Март, 2013 год
#
# Автор - Владимир Андреев
#
# E-Mail: volodya@netfolder.ru

# Обработчики запросов

class Handlers
	#

	version: () ->
		readTime++
	
		Storage.findOne(uid: req.uid, (err, doc) ->
			if err?
				res.send(503)
			else
				vers = if doc? then doc.version else -1

				uncache(req.uid, vers, () -> undefined)
			
				res.json(version: vers)
		)
	
	#

	save: () ->
		writeTime++
	
		fields = {}
		fields['data.' + key] = val for key, val of req.body
		
		Storage.findOneAndUpdate((uid: req.uid), ($inc: (version: 1), $set: fields), (upsert: true), (error, doc) ->
			if error?
				res.send(503)
			else
				uncache(req.uid, doc.version + 1, (status) ->
					res.send(status)
				)
		)

	#

	read: () ->
		readTime++
	
		Storage.findOne(uid: req.uid, (err, doc) ->
			if err?
				res.send(503)
			else
				if req.query.counter?
					res.json(if doc? then doc.tags else {})
				else
					res.json(if doc? then doc.data else {})
		)
		
	#

	saveCounter: () ->
		writeTime++
	
		tg = req.query.tg.split('.')
		
		unless tg.length is 1 and tg[0] is ''
			tags = {}
			tags['tags.' + key] = 1 for key in tg
		
			Storage.update((uid: req.uid), ($inc: tags, $set: (last_visit: Math.floor(new Date() / 1000))), (error) ->
				if error?
					res.send(503)
				else
					res.send(200)
			)
			
		else
			res.send(200)

# Объекты для экспорта

module.exports = Handlers
