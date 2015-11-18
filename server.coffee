App = require 'app'
Db = require 'db'
Event = require 'event'

exports.onInstall = ->
	Db.admin.set 'key', (0|Math.random()*999999)

exports.onHttp = (request) ->
	# special entrypoint for the Http API: called whenever a request is made to our plugin's inbound URL
	if (0|request.path[0]) != Db.admin.get('key')
		log "invalid key"
		return request.respond 403, "invalid key"
	data = JSON.parse request.data
	if !data || (!data.text && !data.title)
		log "invalid data: #{request.data}"
		return request.respond 501, "invalid data"

	# Try to match names

	commentLog = data.log
	delete data.log
	sendEvent = data.event ? (data.level in ['okay','fail'])
	delete data.event
	names = null
	data.memberIds = memberIds = []
	data.t = 0|App.time()
	log data.text
	memberIdHash = {}

	for what in ['text','title'] when typeof data[what] is 'string'
		data[what] = data[what].replace /{{([^}]+)}}/g, (m,name) ->
			if !names
				names = {}
				for memberId in App.userIds()
					names[memberId] = App.userName(memberId)
				log JSON.stringify names
			match = null
			for id,memberName of names
				if (name+" ").indexOf(memberName+" ")==0
					if match?
						match = false
					else
						match = id

			if match && !memberIdHash[match]
				memberIdHash[match] = true
				memberIds.push match

			"**#{if match then names[match] else name}**"
		
	Db.shared.set 'current', data

	if commentLog != false
		commentId = Db.shared.incr '_comments', 'max'
		Db.shared.set '_comments', commentId, data

	request.respond 200, "OK\n"

	if sendEvent and data.title
		Event.create
			text: data.title
			for: memberIds

