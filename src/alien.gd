class_name Alien extends Area2D

var regionId : int = -1

func _ready() -> void:
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	add_to_group("aliens")

func _on_mouse_entered() -> void:
	pass
	
func _on_mouse_exited() -> void:
	pass

func kill() -> void:
	queue_free()
