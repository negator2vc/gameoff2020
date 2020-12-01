class_name AlienSite extends Area2D

export(int) var regionId : int = -1

func _ready() -> void:
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	add_to_group("alienSites")

func _on_mouse_entered() -> void:
	pass
	
func _on_mouse_exited() -> void:
	pass

func destroy() -> void:
	queue_free()
