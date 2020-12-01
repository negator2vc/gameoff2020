class_name HUD extends CanvasLayer

onready var timeLabel : Label = $TimePanel/TimeLabel

var worldScreen : Node2D

func _ready() -> void:
	hideHud()
	$MessageBox.hide()

func init(_worldScreen : Node2D) -> void:
	worldScreen = _worldScreen

func updateTime() -> void:
	timeLabel.text = "Time Left: " + str(Game.remainingTurns) + " hours"

func updateObjectives() -> void:
	$ObjectivePanel/ObjectivesLabel.text = "Alien Structures: " + str(worldScreen.getAlienSitesCount())

func showTitle() -> void:
	$TitlePanel.show()

func hideTitle() -> void:
	$TitlePanel.hide()

func hideHud() -> void:
	$TimePanel.hide()
	$ObjectivePanel.hide()
	$BottomPanel.hide()

func showHud() -> void:
	$TimePanel.show()
	updateTime()
	if Game.hasSeenAlienSite:
		$ObjectivePanel.show()

func msg(text : String) -> void:
	yield($MessageBox.showMessage(text), "completed")

func isMsgBoxVisible() -> bool:
	return $MessageBox.visible 

func showObjectives() -> void:
	$ObjectivePanel.show()
	updateObjectives()
