# Необходимые модули

uncache = require './uncache'

#

app = require('./app')
Storage = require('./models/storage')

# Возвращает версию данных

app.get('/version/', (req, res) ->
	Storage.findOne(uid: req.uid, (err, doc) ->
		if err?
			res.send(503)
		else
			vers = if doc? then doc.version else -1

			uncache(req.uid, vers, () -> undefined)
		
			res.json(version: vers)
	)
)

# Возвращает данные

app.get('/data/', (req, res) ->
	Storage.findOne(uid: req.uid, (err, doc) ->
		if err?
			res.send(503)
		else
			res.json(if doc? then doc.data else {})
	)
)

# Сохраняет данные

app.post('/set/', (req, res) ->
	if Object.keys(req.body).length isnt 0
		Storage.findOne(uid: req.uid, (err, doc) ->
			if err?
				res.send(503)
			else
				unless doc?
					doc = new Storage(uid: req.uid, data: req.body)

					doc.save(
						() -> uncache(req.uid, 0, (status) ->
							res.send(status)
						)
					)
				else
					doc.data[key] = val for key, val of req.body

					Storage.update((_id: doc._id), $inc: (version: 1), $set: (data: doc.data),
						() -> uncache req.uid, doc.version + 1, (status) -> res.send status
					)
		)
	else
		res.send(200)
)

# Сохраняет данные счетчика

app.get('/setcounter/', (req, res) ->
	Storage.findOne(uid: req.uid, (err, doc) ->
		if err? or not req.query.tg?
			res.send(503)
		else
			tg = req.query.tg.split('.')
			
			if tg.length is 1 and tg[0] is ''
				tags = {}
				
				unless doc?
					tags[key] = 1 for key in tg
	
					doc = new Storage(uid: req.uid, tags: tags)
	
					doc.save(
						() -> uncache(req.uid, 0, (status) ->
							res.send(status)
						)
					)
				else
					tags['tags.' + key] = 1 for key in tg
	
					Storage.update((_id: doc._id), ($inc: tags),
						() -> uncache(req.uid, doc.version, (status) ->
							res.send(status)
						)
					)
			else
				res.send(200)
	)
)