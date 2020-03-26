extends Node2D

var imageTexture : ImageTexture
var image : Image
var radius = 50.0
var erase = Color(0.0, 0.0, 0.0, 0.0)
var complete_percentage = 0.5
var scratched_amount = 0.0
var num_pixels
const fillIntensity = 48
const circleIntensity = 120

var eraser : Image 
var eraserMask : Image
var eraserSize = 0
var alphaOne = Color(0.0, 0.0, 0.0, 1.0)
var intDelta = 0.0

var textureDict = {}
var scratcher_texture

func _init():
	initEraser()
	initTextures()

func initTextures():
	textureDict["ampersand"] = load("res://assets/scratchertiles119/ampersand.png")
	textureDict["at"] = load("res://assets/scratchertiles119/at.png")
	textureDict["dollar"] = load("res://assets/scratchertiles119/dollar.png")
	textureDict["flower"] = load("res://assets/scratchertiles119/flower.png")
	textureDict["music"] = load("res://assets/scratchertiles119/music.png")
	textureDict["percent"] = load("res://assets/scratchertiles119/percent.png")
	textureDict["pound"] = load("res://assets/scratchertiles119/pound.png")
	scratcher_texture = load("res://assets/scratcher3.png")

func initEraser():
	eraser = Image.new()
	eraserMask = Image.new()
	eraser.create(radius*2, radius*2,false,Image.FORMAT_RGBA8)
	eraserMask.create(radius*2, radius*2,false,Image.FORMAT_RGBA8)
	var x = radius
	var y = radius
	var i = 0
	var angle
	var x1
	var y1
	
	var j 
	var x2
	var y2
	
	eraser.fill(Color(1.0,0.0,0.0,1.0))
	eraser.lock()
	eraserMask.lock()
	# erase outline
	while i < 2*PI:
		angle = i
		x1 = radius * cos(angle)
		y1 = radius * sin(angle)
		
		# erase fill
		j = 0
		while j < radius:
			x2 = j * cos(angle)
			y2 = j * sin(angle)
			if (x + x2 < 0) or (x + x2 >= eraser.get_width()):
				j+=radius/fillIntensity
				continue
			if (y+y2 < 0) or (y+y2 >= eraser.get_height()):
				j+=radius/fillIntensity
				continue
			var prev_color = eraser.get_pixel(x + x2, y+y2)
			if prev_color.a > 0:
				eraserSize+=1
			eraser.set_pixel(x + x2, y+y2, erase)
			eraserMask.set_pixel(x + x2, y+y2, alphaOne)
			j+=radius/fillIntensity
		if (x + x1 < 0) or (x + x1 >= eraser.get_width()):
			i += PI/circleIntensity
			continue
		if (y+y1 < 0) or (y+y1 >= eraser.get_height()):
			i += PI/circleIntensity
			continue
		var prev_color = eraser.get_pixel(x + x1, y+y1)
		if prev_color.a > 0:
			eraserSize+=1
		eraser.set_pixel(x + x1, y+y1, erase)
		eraserMask.set_pixel(x + x2, y+y2, alphaOne)
		i += PI/circleIntensity
	eraser.unlock()
	eraserMask.unlock()

func _ready():
	imageTexture = ImageTexture.new()
	image = $Scratcher.get_texture().get_data()
	num_pixels = image.get_height() * image.get_width()
	resetScratcher()

func _process(delta):
	if scratched_amount / num_pixels > complete_percentage:
		$Scratcher.set_texture(null)
		$ScratcherTimer.start(2)
		scratched_amount = 0.0

func _input(event):
	if $Scratcher.get_texture() == null: return
	if event is InputEventScreenTouch and event.pressed:
		image = $Scratcher.get_texture().get_data()
		
		image.lock()
		eraseCircle(event.position.x, event.position.y)
		image.unlock()
		#image.blit_rect_mask(eraser,eraserMask,eraser.get_used_rect(),Vector2(event.position.x - radius,event.position.y - radius))
		
		imageTexture.create_from_image(image)
		$Scratcher.set_texture(imageTexture)
	if event is InputEventScreenDrag:
		var target = event.position + event.relative
		var temp = event.position
		var starting_distance = temp.distance_to(target)
		image = $Scratcher.get_texture().get_data()
		image.lock()
		while temp.distance_to(event.position) < starting_distance:
			eraseCircle(temp.x, temp.y)
			#image.blit_rect_mask(eraser,eraserMask,eraser.get_used_rect(),Vector2(event.position.x - radius,event.position.y - radius))
			temp += (event.relative.normalized() * event.speed)
		image.unlock()
		imageTexture.create_from_image(image)
		$Scratcher.set_texture(imageTexture)
		
func eraseCircle(x, y):
	var i = 0
	var angle
	var xOutline
	var yOutline
	
	var j
	var xFill
	var yFill

	# erase outline
	while i < 2*PI:
		angle = i
		xOutline = radius * cos(angle)
		yOutline = radius * sin(angle)
		
		# erase fill
		j = 0
		while j < radius:
			xFill = j * cos(angle)
			yFill = j * sin(angle)
			if (x + xFill < 0) or (x + xFill >= image.get_width()):
				j+=radius/fillIntensity
				continue
			if (y+yFill < 0) or (y+yFill >= image.get_height()):
				j+=radius/fillIntensity
				continue
			var prev_color = image.get_pixel(x + xFill, y+yFill)
			if prev_color.a > 0:
				scratched_amount+=1
			image.set_pixel(x + xFill, y+yFill, erase)
			j+=radius/fillIntensity
		
		if (x + xOutline < 0) or (x + xOutline >= image.get_width()):
			i += PI/circleIntensity
			continue
		if (y+yOutline < 0) or (y+yOutline >= image.get_height()):
			i += PI/circleIntensity
			continue
		var prev_color = image.get_pixel(x + xOutline, y+yOutline)
		if prev_color.a > 0:
			scratched_amount+=1
		image.set_pixel(x + xOutline, y+yOutline, erase)
		
		i += PI/circleIntensity
		
func resetScratcher():
	var keys = textureDict.keys()
	for i in range(0,3):
		for j in range(0,3):
			var index = randi() % keys.size()
			get_node("Result/grid" + String(i) +  String(j)).texture = textureDict.get(keys[index])
	$Scratcher.set_texture(scratcher_texture)

func _on_ScratcherTimer_timeout():
	resetScratcher()
	print("tick")
