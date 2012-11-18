mongoose = require('../mongo')

Schema = mongoose.Schema
ObjectId = Schema.Types.ObjectId
Mixed = Schema.Types.Mixed

Stat = new Schema
	_id :
		type: Mixed
		index: true
	counter:
		type: Number
		index: false
		default: 0
	time:
		type: Number
		index: false
		default: 0

Model = module.exports = mongoose.model 'Stat', Stat
