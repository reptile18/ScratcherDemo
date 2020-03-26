extends Resource

class TileKeeper:
	extends Object
	var dict = {}
	# return a random tile
	func randTileTex():
		var keys = dict.keys()
		var index = randi() % keys.size()
		return dict[keys[index]]
		pass

func _init():
	TileKeeper.dict["ampersand"] = load("res://assets/scratchertiles119/ampersand.png")
	TileKeeper.dict["at"] = load("res://assets/scratchertiles119/at.png")
	TileKeeper.dict["dollar"] = load("res://assets/scratchertiles119/dollar.png")
	TileKeeper.dict["flower"] = load("res://assets/scratchertiles119/flower.png")
	TileKeeper.dict["music"] = load("res://assets/scratchertiles119/music.png")
	TileKeeper.dict["percent"] = load("res://assets/scratchertiles119/percent.png")
	TileKeeper.dict["pound"] = load("res://assets/scratchertiles119/pound.png")
	pass