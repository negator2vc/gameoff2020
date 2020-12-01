class_name Region extends Area2D

signal regionSelected

export(int) var id : int = 1
export(Array) var adjacentRegions : Array = [0, 0, 0, 0]

var selected = false

func _ready() -> void:
	connect("input_event", self, "_on_Region_input_event")
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")

func _on_Region_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() == false:
		emit_signal("regionSelected", id, self)

func _on_mouse_entered() -> void:
	selected = true
	update()

func _on_mouse_exited() -> void:
	selected = false
	update()

func _draw() -> void:
	if selected:
		var borderColor : Color = Game.kBorderColorInvalidRegion
		if Game.currentRegion in adjacentRegions:
			borderColor = Game.kBorderColorAdjacentRegion
		for i in range($CollisionPolygon2D.polygon.size()):
			if i < $CollisionPolygon2D.polygon.size() - 1:
				draw_line($CollisionPolygon2D.polygon[i], $CollisionPolygon2D.polygon[i+1], borderColor, 6.0)
			else:
				draw_line($CollisionPolygon2D.polygon[i], $CollisionPolygon2D.polygon[0], borderColor, 6.0)

func getPlayerPos() -> Vector2:
	return $PlayerPosition.global_position

func getAlienSpawnPosition() -> Vector2:
	return $AlienSpawnPosition.global_position

func findAvailableAlienPosition(mapAliens):
	var isAvailable = true
	for alienPos in $AlienPositions.get_children():
		isAvailable = true
		for mapAlien in mapAliens:
			if mapAlien.regionId == id and mapAlien.global_position == alienPos.global_position:
				isAvailable = false
		if isAvailable == true:
			return alienPos.global_position
	return null
