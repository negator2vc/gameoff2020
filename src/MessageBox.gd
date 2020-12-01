class_name MessageBox extends NinePatchRect

signal messageBoxClosed

export(String) var closeAction : String = "closeMessageBox"

onready var messageBoxLabel : Label = $Label

func showMessage(text : String) -> void:
	show()
	messageBoxLabel.text = text
	yield(self, "messageBoxClosed")
	hide()

func _input(event: InputEvent) -> void:
	if closeAction != "" and event.is_action_pressed(closeAction) and visible == true:
		emit_signal("messageBoxClosed")
