mongoose = require('../mongo')

Schema = mongoose.Schema
ObjectId = Schema.Types.ObjectId
Mixed = Schema.Types.Mixed

Statistic = new Schema
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

Model = module.exports = mongoose.model 'Statistic', Statistic
