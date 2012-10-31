app = require('./app')

exports = module.exports = (req, res, next) ->
	uid = req.query.uid

	if uid?
		req.uid = uid
		next()
	
	else 
		res.send 403