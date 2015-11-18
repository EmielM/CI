App = require 'app'
Comments = require 'comments'
Db = require 'db'
Dom = require 'dom'
Icon = require 'icon'
Ui = require 'ui'

levels =
	fail: ['warn', '#a70b05']
	busy: ['hourglass', '#db8e00']
	okay: ['good', '#008000']


exports.render = ->

	Dom.section !->
		Dom.div !->
			renderMessage Db.shared.ref('current'), true
	if App.memberIsAdmin()
		Dom.div !->
			Dom.style fontSize: '85%', textAlign: 'right', color: '#777', _userSelect: 'text'
			Dom.text App.inboundUrl()+'/'+Db.admin.get('key')

	Comments.enable
		render: (msgO) !->
			if msgO.peek('level')
				Dom.div !->
					renderMessage msgO
				return true

Dom.css
	'.msg section':
		border: 0


renderMessage = (msgO, large) !->
	scale = if large then 1.25 else 1
	Dom.style
		Box: 'middle'
		position: 'relative'
		minHeight: (46*scale)+'px'

	level = msgO.get('level')
	[icon,color] = if level instanceof Array then level else (levels[level]||[])
	Icon.render
		data: icon || 'cogwheel'
		color: color || '#555'
		size: scale*38
		style:
			position: 'absolute'
			right: 0
			top: "4px"

	Dom.div !->
		Dom.style Box: "vertical center"
		for memberId in msgO.get('memberIds')||[]
			Ui.avatar App.memberAvatar(memberId),
				onTap: !-> log "No App.memberInfo yet"
				size: scale*38

	Dom.div !->
		Dom.cls 'msg'
		Dom.style
			Flex: 1,
			fontSize: (if large then '135%' else '100%')
			margin: "4px "+(scale*(4+38))+'px 4px '+(scale*4)+'px'
			_userSelect: 'text'
		if title = msgO.get('title')
			Dom.div !->
				Dom.style
					fontSize: '110%'
					textTransform: 'uppercase'
					borderBottom: '2px solid'
					color: '#888'
					paddingBottom: '2px'
					marginBottom: '2px'
				Dom.userText title, {br:false,url:false}
		if text = msgO.get('text')
			Dom.userText text
		if !text && !title
			Dom.text 'no status yet'

