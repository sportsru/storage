app = require './app'
uncache = require './uncache'
Storage = require './models/storage'

app.get '/version/', (req, res) ->
	Storage.findOne uid: req.uid, (err, doc) ->
		vers = -1
		if not(err? or not doc?)			
			vers = doc.version
			
		uncache req.uid, vers, () -> undefined
		res.json
			version: vers

app.post '/set/', (req, res) ->
	if Object.keys(req.body).length isnt 0
		Storage.findOne uid: req.uid, (err, doc) ->
			if err?
				res.send 503
			else
				if not doc?
					doc = new Storage 
						uid: req.uid
						data: req.body

					doc.save () -> uncache req.uid, 0, (status) -> res.send status
				else
					for key, val of req.body
						doc.data[key] = val

					Storage.update _id: doc._id,
						$inc: 
							version: 1
						$set:
							data: doc.data
					,
						() -> uncache req.uid, doc.version + 1, (status) -> res.send status
	else
		res.send 200

app.get '/setcounter/', (req, res) ->
                Storage.findOne uid: req.uid, (err, doc) ->
                        if err?
                                res.send 503
                        else
                                tg = req.query.tg.split('.')
                                tags = {}

                                if not doc? 
	                                for i, key of tg
        	                                tags[key] = 1

                                        doc = new Storage
                                                uid: req.uid
                                                tags: tags

                                        doc.save () -> uncache req.uid, 0, (status) -> res.send status
                                else
        	                        for i, key of tg
	                                        tags['tags.' + key] = 1

                                        Storage.update _id: doc._id,
                                                $inc: tags,
                                                () -> uncache req.uid, doc.version, (status) -> res.send status


app.get '/data/', (req, res) ->
	Storage.findOne uid: req.uid, (err, doc) ->
		res.json if doc? then doc.data else {}
