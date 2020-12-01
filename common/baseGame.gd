# BaseGame script module v1.3
# last updated 2020.12.01

extends Node

var version = [0, 0, 1]
var currentScene = null

func _ready():
	var root = get_tree().get_root()
	currentScene = root.get_child(root.get_child_count() -1)
	randomize()

func gotoScene(name):
	call_deferred("gotoSceneDeferred", "res://" + name + ".tscn")

func gotoSceneDeferred(path):
	currentScene.free()
	var newScene = ResourceLoader.load(path)
	currentScene = newScene.instance()
	get_tree().get_root().add_child(currentScene)

func getVersion():
	if version[2] > 0:
		return "v" + str(version[0]) + "." + str(version[1]) + "." + str(version[2])
	else:
		return "v" + str(version[0]) + "." + str(version[1])

func quit() -> void:
	get_tree().quit()

func takeScreenshot() -> void:
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var image = get_viewport().get_texture().get_data()
	image.flip_y()
	
	var dtDict = OS.get_datetime()
	var dtString = str(dtDict["year"])
	if dtDict["month"] < 10: dtString += "0"
	dtString += str(dtDict["month"])
	if dtDict["day"] < 10: dtString += "0"
	dtString += str(dtDict["day"])
	dtString += "_"
	if dtDict["hour"] < 10: dtString += "0"
	dtString += str(dtDict["hour"])
	if dtDict["minute"] < 10: dtString += "0"
	dtString += str(dtDict["minute"])
	if dtDict["second"] < 10: dtString += "0"
	dtString += str(dtDict["second"])
	
	image.save_png("user://screenshot_" + dtString + ".png")
