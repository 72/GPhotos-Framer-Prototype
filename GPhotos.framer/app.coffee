# Prototype: GPhotos
# by: @72mena

{Pointer} = require "Pointer"

###########################################
# VARS
###########################################
tiles = []
bubbles = []
dragRange = []

selectMode = false
dragRangeMode = false

customDelay = 500
counter = 0
origin = 0

scrollOffset = 0
customTimer = null

###########################################
# SETTING UP LAYERS
# - - - - - - - - - 
# bg
# app
# -- menu
# -- home
# ---- header
# ---- scrollPhotos (scrollComponent)
# -------- content
# ---------- scrollContent
# ---- scrollCollections
# ---- scrollAssistant
###########################################
bg = new BackgroundLayer

app = new Layer
	width: Screen.width
	height: Screen.height
	backgroundColor: null


###
HOME
###
home = new Layer
	width: Screen.width
	height: Screen.height
	backgroundColor: null
	superLayer: app

home.states.add
	showMenu:
		x: Screen.width

# HEADER ELEMENTS
header = new Layer
	width: Screen.width
	height: 160
	backgroundColor: '#FFF'
	superLayer: home
header.style =
	'borderBottom': '1px solid #BBB'

leftHotspot = new Layer
	superLayer: header
	x: 20, y: 50
	backgroundColor: null

# Line 72!
hamburgerIcon = new Layer
	width: 80, height: 80
	image: 'images/hamb.png'
	superLayer: leftHotspot
hamburgerIcon.center()
hamburgerIcon.states.add
	show:
		opacity: 1
	hide: 
		opacity: 0
hamburgerIcon.states.animationOptions =
	curve: "spring(500,50,0)"


closeIcon = new Layer
	backgroundColor: null
	height: 36, width: 36
	x: 20, y: 31
	opacity: 0
	superLayer: leftHotspot
	image: 'images/close.png'

mainLabel = new Layer
	superLayer: header
	x: leftHotspot.maxX, y: 86
	height: 40, width: 200
	clip: false
	html: 'Photos'
	backgroundColor: null
	color: '#444'

mainLabel.style =
	"font-size":"48px"
	"font-family": "sans-serif"
	"font-weight":"300"
	
header.states.add 
	selectMode:
		backgroundColor: "#2196F3"
	normalMode:
		backgroundColor: "#FFF"
header.states.animationOptions =
	curve: "spring(200,30,0)"

# MAIN COMPONENT
sectionHolder = new PageComponent
	width: Screen.width
	height: Screen.height-160
	y: 160
	superLayer: home
	scrollVertical: false
	directionLock: true
	#scrollHorizontal: false

# ACTIVITY
scrollAssistant = new ScrollComponent
	width: Screen.width
	height: Screen.height-160
	backgroundColor: "#EEE"
	superLayer: sectionHolder.content
	scrollHorizontal: false
	directionLock: true

scrollAssistantContent = new Layer
	width: Screen.width
	height: 2800
	superLayer: scrollAssistant.content
	image: "images/pageAssistant.jpg" 

# COLLECTIONS
scrollCollections = new ScrollComponent
	width: Screen.width
	height: Screen.height-160
	backgroundColor: "#FFF"
	superLayer: sectionHolder.content
	scrollHorizontal: false
	directionLock: true

scrollCollectionsContent = new Layer
	width: Screen.width
	height: 1540
	superLayer: scrollCollections.content
	image: "images/pageCollections.jpg"

# PHOTOS
scrollPhotos = new ScrollComponent
	width: Screen.width
	height: Screen.height-160
	backgroundColor: null
	scrollHorizontal: false
	directionLock: true

sectionHolder.addPage scrollPhotos
sectionHolder.addPage scrollCollections

scrollContent = new Layer
	width: Screen.width
	height: Screen.height
	superLayer: scrollPhotos.content
	backgroundColor: '#FFF'

# This Layer is used for Desktop Gesture Events
Viewport = new Layer
	width: Screen.width
	height: Screen.height
	y: 150
	backgroundColor: null
	opacity: 0
	visible: false
	superLayer: home


###
MENU
###
menu = new Layer
	width: 638
	height: Screen.height
	x: -638
	backgroundColor: null
	superLayer: app

menuBG = new Layer
	width: Screen.width
	height: Screen.height
	opacity: 0
	visible: false
	backgroundColor: 'black'
	superLayer: home

menuContent = new Layer
	width: 638, height: Screen.height
	image: 'images/menuContent.jpg'
	shadowColor: "black"
	shadowBlur: 60
	shadowSpread: 10
	superLayer: menu

menuOptions = new Layer
	y: 320
	width: 638, height: 289
	image: 'images/optionPhotos.png'
	superLayer: menuContent

hsAssistant = new Layer
	width: 638, height: 90
	backgroundColor: null
	superLayer: menuOptions

hsPhotos = new Layer
	y: 98
	width: 638, height: 90
	backgroundColor: null
	superLayer: menuOptions

hsCollections = new Layer
	y: 195
	width: 638, height: 90
	backgroundColor: null
	superLayer: menuOptions


menu.draggable.enabled = true
menu.draggable.vertical = false

menu.states.add
	show:
		x: 0
	hide:
		x: -638

menuBG.states.add
	show:
		opacity: 0.6
	hide:
		opacity: 0

menu.states.animationOptions =
	curve: "spring(500,50,0)"

menuBG.states.animationOptions =
	curve: "spring(500,50,0,5)"



###########################################
# EVENTS
###########################################
leftHotspot.on Events.Click, ->
	if selectMode
		exitSelectMode()
	else
		bringMenu()

menuBG.on Events.Click, ->
	if menuBG.states.current is "show"
		menu.states.switch "hide"
		menuBG.states.switch "hide"
		

menuBG.on Events.AnimationEnd, ->
	if menuBG.states.current is "hide"
		menuBG.visible = false

menu.on Events.Move, ->
	menuBG.opacity = Utils.modulate(menu.x, [0, -300], [0.6, 0.2], true)
	if menu.x > 0
		menu.x = 0

menu.on Events.DragEnd, ->
	if menu.x > -200
		menu.states.switch "show"
		menuBG.states.switch "show"
	else
		menu.states.switch "hide"
		menuBG.states.switch "hide"


hsAssistant.on Events.Click, ->
	if not menu.draggable.isDragging
		menuOptions.image = "images/optionAssistant.png"
		hideMenu("Assistant")
		#menu.states.switch "hide"
		#menuBG.states.switch "hide"

hsPhotos.on Events.Click, ->
	if not menu.draggable.isDragging
		menuOptions.image = "images/optionPhotos.png"
		hideMenu("Photos")

hsCollections.on Events.Click, ->
	if not menu.draggable.isDragging
		menuOptions.image = "images/optionCollections.png"
		hideMenu("Collections")


###########################################
# FUNCTIONS
# - - - - - - - 
# timer
# forLoop -> setupPhotos
# viewPhoto()
# enterSelectMode()
# exitSelectMode()
# selectDragging()
# reactivateScroll()
# detectDevice
# activate()
# deactivate()
# selectFromTo()
# deselectFromTo()
# bringMenu()
#
###########################################

# customTimer
after = (time, callback) ->
	customTimer = setTimeout callback, time

###
START - SETUP PHOTOS
###
gap = 10
sizeFit = (Screen.width/4) - (gap/2)

# Based on a 4x11 grid
for i in [0..10]
	for j in [0..3]
		
		counter++
		# Tile Background
		sqBg = new Layer
			width: sizeFit, height: sizeFit
			x: j*(sizeFit+gap), y: i*(sizeFit+gap)
			name: 'tileBG'
			backgroundColor: '#F9F9F9'
			superLayer: scrollContent
		
		# Photo
		sq = new Layer
			width: sizeFit, height: sizeFit
			x: j*(sizeFit+gap), y: i*(sizeFit+gap)
			image: "images/#{counter}.png"
			name: counter
			backgroundColor: '#EEE'
			clip: false
			superLayer: scrollContent
		
		# Indicator (bubble?)
		bubble = new Layer
			width: Math.floor(sq.width*0.22)
			height: Math.floor(sq.width*0.22)
			x: sq.x+8, y: sq.y+8
			borderRadius: 20
			backgroundColor: null
			superLayer: scrollContent
			opacity: 0
		bubble.style =
			"border":"4px solid #FFF"
		
		tiles.push sq
		bubbles.push bubble
					
		# Events for Tile
		sq.on Events.TouchStart, ->
			
			if not sectionHolder.isMoving
				# saving scope 
				_sq = this
				
				# [1/2] Better scrolling detection
				# than .isMoving / .isDragging
				scrollOffset = scrollPhotos.scrollY
				
				# Detect Long Press after x milliseconds
				after customDelay, ->
					
					if not sectionHolder.isMoving
						# [2/2] Scrolling detection, allowing small threshold
						_thisOffset = Math.abs(scrollPhotos.scrollY - scrollOffset)
						if _thisOffset < 30
							# ACTIVATE SELECT MODE!
							enterSelectMode(_sq) 
					
		
		sq.on Events.TouchEnd, ->
			
			if not sectionHolder.isMoving
				# Clear timer for Long-Press detection
				clearTimeout customTimer
				_thisOffset = Math.abs(scrollPhotos.scrollY - scrollOffset)
				if _thisOffset < 12
				
					# Case 1. There was a Long-Press
					if dragRangeMode
						reactivateScroll()
						#reactivatePageComponent() unless selectMode
					
					# Case 2. There was a Click
					else
						_num = this.name
						if bubbles[_num-1].image is 'images/check.png'
							deactivate(this)
						else
							if selectMode
								activate(this)
							else
								viewPhoto(this)
				else
					reactivateScroll()
					#reactivatePageComponent() unless selectMode
		
# Update Scroll to fit all elements inside
lastItem = tiles.length - 1
scrollContent.height = tiles[lastItem].maxY
scrollPhotos.updateContent()
###
END - SETUP PHOTOS
###


viewPhoto = (tile) ->
	
	_selected = tile
	
	# Setup
	scrollPhotos.scroll = false
	screenX = _selected.x
	screenY = _selected.y - scrollPhotos.scrollY + 160 
	#scrollPhotos.y
	
	# New Elements
	_modalBG = new Layer
		width: Screen.width, height: Screen.height
		backgroundColor: 'black'
		opacity: 0
		superLayer: home
	
	_modalTile = _selected.copy()
	_modalTile.superLayer = home
	_modalTile.x = screenX
	_modalTile.y = screenY
	_selected.opacity = 0
	
	_scrollTrick = new ScrollComponent
		superLayer: home
		width: _modalTile.width
		height: _modalTile.height
		x: (Screen.width/2) - (_modalTile.width/2)
		y: (Screen.height/2) - (_modalTile.height/2)
		scale: 4
		backgroundColor: null
	
	_scrollTrick.content.backgroundColor = null
	
	closeOval = new Layer
		superLayer: home
		image: 'images/closeOval.png'
		backgroundColor: null
		y: (Screen.height*0.85)
	closeOval.centerX()
	
	# Animations
	_modalBG.animate
		properties:
			opacity: 0.9
		curve: "spring(800,50,0)"
	
	_modalTile.animate
		properties:
			x: (Screen.width/2) - (_modalTile.width/2)
			y: (Screen.height/2) - (_modalTile.height/2)
			scale: 4
		curve: "spring(800,50,0)"
	
	# Functions
	closeModal = ->
		_modalBG.animate
			properties:
				opacity: 0
			curve: "spring(800,50,0)"
		
		_modalTile.animate
			properties:
				x: screenX
				y: screenY
				scale: 1
			curve: "spring(800,50,0)"
		
		reactivateScroll()
		closeOval.destroy()
		
		Utils.delay 0.4, ->
			_modalBG.destroy()
			_modalTile.destroy()
			_scrollTrick.destroy()
			_selected.opacity = 1
	
	# Events	
	_modalBG.on Events.Click, ->
	
	_modalTile.on Events.Click, ->
		closeModal()
	
	closeOval.on Events.Click, ->
		closeModal()
	
	_scrollTrick.on Events.Move, ->
		_dragX = Math.abs(_scrollTrick.scrollX)
		_dragY = Math.abs(_scrollTrick.scrollY)
		
		_modalTile.scale = Utils.modulate(_dragY, [0, 80], [4, 1.6], true)
		_modalBG.opacity = Utils.modulate(_dragY, [0, 80], [0.9, 0.2], true)
		
	
	_scrollTrick.on Events.ScrollEnd, ->
		if _modalTile.scale < 3.4
			closeModal() 
				
# / close viewPhoto()


# Select Mode
enterSelectMode = (tile) ->
	
	# setup
	header.states.switch 'selectMode'
	closeIcon.opacity = 1
	hamburgerIcon.states.switch 'hide'
	selectMode = true
	dragRangeMode = true
	#deactivate scrolls
	sectionHolder.scroll = false
	scrollPhotos.scroll = false
	
	Viewport.visible = true
	mainLabel.animate
		properties:
			color: "#FFF"
		time: 0.4
	
	# show indicators
	for bubble in bubbles
		bubble.opacity = 1
	
	# activate this tile
	activate(tile)
	
	Utils.delay 0.3, ->
		mainLabel.style =
			"font-weight":"bold"


# Exit Select Mode
exitSelectMode = ->
	selectMode = false
	closeIcon.opacity = 0
	hamburgerIcon.states.switch 'show'
	header.states.switch 'normalMode'
	for item in tiles
		deactivate(item)
	mainLabel.animate
		properties:
			color: "#333"
		time: 0.3
	Utils.delay 0.3, ->
		reactivatePageComponent()
		mainLabel.html = 'Photos'
		mainLabel.style =
			"font-weight":"normal"


# SelectDragging Logic
selectDragging = (pX, pY) ->
	for tile, i in tiles
		
		# if Pointer is above a tile
		if pX > tile.minX and pX < tile.maxX and pY > tile.minY and pY < tile.maxY
			
			# if tile isnt already in our array
			if tile.name not in dragRange
				activate(tile)
				dragRange.push tile.name
				if dragRange.length is 1
					origin = tile.name
									
			# SelectDrag is happening: select/deselect accordingly
			if dragRange.length is 2
				
				if dragRange[0] >= origin and dragRange[1] > origin
					#print 'selecting items after origin'
					if dragRange[0] < dragRange[1]
						selectFromTo(dragRange[0], dragRange[1])
					else if dragRange[0] > dragRange[1]
						deselectFromTo(dragRange[0], dragRange[1])
				
				else if dragRange[0] <= origin and dragRange[1] < origin
					#print 'selecting items before origin'
					if dragRange[0] < dragRange[1]
						deselectFromTo(dragRange[0], dragRange[1])
					if dragRange[0] > dragRange[1]
						selectFromTo(dragRange[0], dragRange[1])
				
				else if dragRange[0] < origin and dragRange[1] > origin
					# print 'EDGE CASE: selecting items after origin, but with items previously selected before origin'
					deselectFromTo(dragRange[0], origin)
					selectFromTo(origin, dragRange[1])
				
				else if dragRange[0] > origin and dragRange[1] < origin
					# print 'EDGE CASE: selecting items before origin, but with items previously selected after origin'
					deselectFromTo(dragRange[0], origin)
					selectFromTo(origin, dragRange[1])
				
				else if dragRange[1] is origin
					#print 'selection went back to origin!'
					if dragRange[0] < dragRange[1]
						deselectFromTo(dragRange[0], dragRange[1])
					if dragRange[0] > dragRange[1]
						deselectFromTo(dragRange[0], dragRange[1])
									
				dragRange = []
				dragRange.push tile.name

# / close SelectDragging

reactivatePageComponent = ->
	sectionHolder.scroll = true
	sectionHolder.scrollVertical = false
	sectionHolder.directionLock = true

reactivateScroll = ->
	dragRange = []
	origin = 0
	Viewport.visible = false
	
	scrollPhotos.scroll = true
	scrollPhotos.scrollHorizontal = false
	scrollPhotos.directionLock = true
	


###
DETECT DEVICE, SET EVENTS ACCORDINGLY
###
if Utils.isPhone()
	#PHONE
	Events.wrap(window).addEventListener "touchmove", (e) ->
		if dragRangeMode
			pointX = e.touches[0].screenX
			pointY = e.touches[0].screenY
			
			if pointY > (Screen.height*0.91)
				scrollPhotos.scrollY = scrollPhotos.scrollY + 8
			else if pointY < (Screen.height*0.20)
				scrollPhotos.scrollY = scrollPhotos.scrollY - 8
			
			pY = (pointY - 150) + scrollPhotos.scrollY
			selectDragging(pointX, pY)
	
	Events.wrap(window).addEventListener "touchend", (e) ->
		dragRangeMode = false
		reactivateScroll()

else
	#DESKTOP
	Viewport.on Events.TouchMove, (e, l) ->
		if dragRangeMode
			point = Pointer.offset(e, l)
			
			if point.y > (Viewport.height*0.80)
				scrollPhotos.scrollY = scrollPhotos.scrollY + 10
			else if point.y < (Viewport.height*0.10)
				scrollPhotos.scrollY = scrollPhotos.scrollY - 10
			
			pY = point.y + scrollPhotos.scrollY
			selectDragging(point.x, pY)
									
	Viewport.on Events.TouchEnd, (e, l) ->
		dragRangeMode = false
		reactivateScroll()



###
DE-&-ACTIVATE ITEMS
###
activate = (item) ->
	_num = item.name
	bubbles[_num-1].opacity = 1
	bubbles[_num-1].image = 'images/check.png'
	bubbles[_num-1].animate 
		properties:
			backgroundColor: '#2196F3'
			borderColor: '#2196F3'
			scale: 1.1
		curve: 'spring(500,20,20)'
	item.animate
		properties:
			scale: 0.80
			backgroundColor: '#DFDFDF'
		curve: 'spring(500,50,0)'
	
	_counter = 0
	for bubble, i in bubbles
		if bubble.image is 'images/check.png'
			_counter++
			mainLabel.html = _counter

	

deactivate = (item) ->
	_num = item.name
	bubbles[_num-1].opacity = 0 unless selectMode
	bubbles[_num-1].image = null
	bubbles[_num-1].animate 
		properties:
			backgroundColor: null
			scale: 1
		curve: 'spring(500,50,0)'
	bubbles[_num-1].style =
			"border":"4px solid #FFF"
	item.animate
		properties:
			scale: 1
			backgroundColor: '#EEE'
		curve: 'spring(500,50,0)'
		
	_counter = 0
	for bubble, i in bubbles
		if bubble.image is 'images/check.png'
			_counter++
			mainLabel.html = _counter unless selectMode is false
	if _counter is 0
		mainLabel.html = '0' unless selectMode is false
		exitSelectMode() unless selectMode is false


###
DE-&-SELECT RANGE
###
selectFromTo = (firstItem, lastItem) ->
	for i in [firstItem..lastItem]
		activate(tiles[i-1])

deselectFromTo = (firstItem, lastItem) ->
	for i in [firstItem...lastItem]
		deactivate(tiles[i-1])

###
MENU
###
bringMenu = () ->
	if menu.states.current isnt "show"
		menuBG.visible = true
		menuBG.states.switch "show"
		menu.states.switch "show"
	else
		menuBG.states.switch "hide"
		menu.states.switch "hide" 


hideMenu = (option) ->	
	if option is "Assistant"
		sectionHolder.snapToPage(scrollAssistant)
	else if option is "Photos"
		sectionHolder.snapToPage(scrollPhotos)
	else if option is "Collections"
		sectionHolder.snapToPage(scrollCollections)
	
	Utils.delay 0.1, ->
		menuBG.states.switch "hide"
		menu.states.switch "hide"


sectionHolder.on "change:currentPage", ->
	if sectionHolder.currentPage	is scrollAssistant
		menuOptions.image = "images/optionAssistant.png"
		mainLabel.html = "Assistant"
	else if sectionHolder.currentPage is scrollPhotos
		menuOptions.image = "images/optionPhotos.png"
		mainLabel.html = "Photos"
	else if sectionHolder.currentPage is scrollCollections
		menuOptions.image = "images/optionCollections.png"
		mainLabel.html = "Collections"


# Start on Photos
sectionHolder.snapToPage(scrollPhotos, false)


# :)


