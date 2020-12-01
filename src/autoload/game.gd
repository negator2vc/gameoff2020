extends "res://common/baseGame.gd"

const kTurnsPerHour : int = 4
const kStartingRegion : int = 1
const kStartingSpawnRate : int = 2

# todo: states mainmenu, actionphase, enemyphase not used yet!!!
enum {
	kStateMainMenu, kStateIntro,
	kStateOnGoing, kStateActionPhase, kStateEnemyPhase,
	kStateWon, kStateLost
}

const kBorderColorAdjacentRegion = Color(0,0.5,0,0.2)
const kBorderColorInvalidRegion = Color(0, 0, 0, 0.2)
const kBorderWidthAdjecentRegion = 6.0
const kBorderWidthInvalidRegion = 3.0

var debugMode = false

var currentRegion := kStartingRegion
var remainingTurns := kTurnsPerHour
var state := kStateIntro
var spawnRate : int = kStartingSpawnRate

var hasSeenAlienSite : bool = false

onready var music : Dictionary = {
	"main" : preload("res://music/Trouble-on-Mercury_Looping.ogg")
}

func _ready() -> void:
	version = [1, 0, 0]		# 2020.12.01
	print(getVersion())
	startGame()

func startGame() -> void:
	currentRegion = kStartingRegion
	remainingTurns = kTurnsPerHour
	state = kStateIntro
	spawnRate = kStartingSpawnRate
	
	hasSeenAlienSite = false

func restartGame() -> void:
	startGame()
	gotoScene("src/worldScreen")
