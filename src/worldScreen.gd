class_name WorldScreen extends Node2D

signal gameStarted

onready var alienScene = preload("res://src/alien.tscn")

onready var tween : Tween = $Tween
onready var landingCraft : Sprite = $Entities/LunarModule
onready var player : Node2D = $Entities/Player
onready var hud : HUD = $HUD

var canDoAction = true
# array of regions already selected as spawn region
# clear at end of turn (begin game, end of turn)
var regionAlreadySelected : Array

func _ready() -> void:
	hud.init(self)
	for region in $Regions.get_children():
		region.connect("regionSelected", self, "_on_regionSelected")
		region.hide()
	player.hide()
	landingCraft.hide()
	player.global_position = getRegionById().getPlayerPos()
	hud.updateTime()
	Audio.playMusic(Game.music.main, -25)

	hud.showTitle()
	yield(self, "gameStarted")
	hud.hideTitle()
	
	var msgText = ""
	
#	RENABLE AFTER TESTING!!!
	msgText += "SHUTTLE 2786: Shuttle 2786 to Control. Approaching moon surface."
	msgText += "\n\nCONTROL: Understood. You mission is to find out what causing the disturbances back on Earth since it seems to be emanating from the dark side of the Moon."
	msgText += "\n\nCONTROL: Be warned Shuttle 2786 that we will not be able to communicate after you land. You will be on your own until you finish your mission and take off."
	msgText += "\n\nSHUTTLE 2786: Understood control. Initiating landing procedures..."
	yield(hud.msg(msgText), "completed")
	
	canDoAction = false
	var landingCraftPos = landingCraft.global_position
	landingCraft.global_position = landingCraftPos - Vector2(0, landingCraftPos.y + 100)
	landingCraft.show()
	tween.interpolate_property(landingCraft, "global_position", landingCraft.global_position, landingCraftPos, 2.0, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_completed")
	yield(get_tree().create_timer(1.5), "timeout")
	player.show()
	yield(get_tree().create_timer(1.0), "timeout")

	msgText = "The ship's scanner shows ... ALIEN LIFE FORMS on the surface! What it's happening here?\n\n"
	msgText += "The scan also shows four artifical structures on the surface. Maybe they are the cause of Earth's problems.\n\n"
	msgText += "Better take my weapon with me. These alien life forms don't look friently!"
	yield(hud.msg(msgText), "completed")

	msgText = "Click on an adjacent location (green border) to move there (take 1 hour).\n\n"
	msgText += "Press (S) to shoot an alien in your location (take 1 hour).\n\n"
	msgText += "Every 4 hours new aliens are spawned at random locations.\nIf an alien is spawned at a location with 3 aliens the alien move to your ship's location.\n\nIf there are 4 or more aliens at your ship's location they overcome your ship's defences and destroy it!\n\n"
	msgText += "Additional controls will become available later in the game."
	yield(hud.msg(msgText), "completed")

	for i in range(Game.spawnRate):
		yield(spawnAlien(), "completed")
	yield(get_tree().create_timer(0.4), "timeout")
	regionAlreadySelected.clear()
	for region in $Regions.get_children():
		region.show()
	hud.showHud()
	Game.state = Game.kStateOnGoing
	canDoAction = true
	
func _on_regionSelected(id, region):
	if canDoAction == false: return
	if id != Game.currentRegion and Game.currentRegion in region.adjacentRegions:
		moveToRegion(id)

func moveToRegion(id : int) -> void:
	canDoAction = false
	tween.interpolate_property(player, "global_position", player.global_position, getRegionById(id).getPlayerPos(), 1.0, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_completed")
	Game.currentRegion = id
	Game.remainingTurns -= 1
	hud.updateTime()
	refreshRegionVisuals()
	
	var alienSite : AlienSite = getCurrentRegionAlienSite()
	if alienSite != null and Game.hasSeenAlienSite == false:
		Game.hasSeenAlienSite = true
		var msgText : String = "This alien structure is emanating a strong signal messing with my instruments.\n"
		msgText += "This is definitively the cause of Earth's problems.\n\n"
		msgText += "The structure is full of the same alien life forms that my ship's scanner found when I arrived. And they are definitively not friendly!\n\n"
		msgText += "It won't be easy but I must destroy this structure and its siblings in order to complete my mission!\n\n\n"
		
		msgText += "Press (A) to try to attack the alien structure (take 1 hour)."
		
		yield(hud.msg(msgText), "completed")
		hud.showObjectives()
	
	if Game.remainingTurns <= 0:
		yield(endTurn(), "completed")
	canDoAction = true
	yield(get_tree(), "idle_frame")

func getRegionById(id : int = -1) -> Region:
	if id < 0:
		id = Game.currentRegion
	return $Regions.get_node("Region" + str(id)) as Region

func spawnAlien() -> void:
	var spawnRegion : Region = getRandomSpawnRegion()
	while regionAlreadySelected.find(spawnRegion) >= 0:
		spawnRegion = getRandomSpawnRegion()
	regionAlreadySelected.push_back(spawnRegion)
	
	var alienInstance = alienScene.instance()
	alienInstance.position = spawnRegion.getAlienSpawnPosition()
	var finalAlienScale = alienInstance.scale
	alienInstance.scale = Vector2(0.1, 0.1)
	alienInstance.regionId = spawnRegion.id
	$Entities/Aliens.add_child(alienInstance)
	tween.interpolate_property(alienInstance, "scale", Vector2(0.1, 0.1), finalAlienScale, 0.5, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_completed")
	
	# move alien either to alien position in region
	# or to the base region if no position available
	var mapAliens = get_tree().get_nodes_in_group("aliens")
	var availableAlienPos = spawnRegion.findAvailableAlienPosition(mapAliens)
	if availableAlienPos != null:
		tween.interpolate_property(alienInstance, "global_position", alienInstance.global_position, availableAlienPos, 1, Tween.TRANS_SINE, Tween.EASE_IN)
		tween.start()
		yield(tween, "tween_completed")
	else:
		alienInstance.regionId = Game.kStartingRegion
		availableAlienPos = getRegionById(Game.kStartingRegion).findAvailableAlienPosition(mapAliens)
		tween.interpolate_property(alienInstance, "global_position", alienInstance.global_position, availableAlienPos, 1, Tween.TRANS_SINE, Tween.EASE_IN)
		tween.start()
		yield(tween, "tween_completed") 
	
	yield(get_tree(), "idle_frame")

func endTurn() -> void:
	canDoAction = false
	for region in $Regions.get_children():
		region.hide()
	regionAlreadySelected.clear()
	
	for i in range(Game.spawnRate):
		yield(spawnAlien(), "completed")
	
	if getBaseRegionAliensCount() > 3:
		var msgText = "The aliens managed to overcome your ship's defenses and destroy it!\n\n"
		msgText += "You are stranded on the moon with no way to return to Earth!\n\n"
		msgText += "THE END!"
		yield(hud.msg(msgText), "completed")
		Game.restartGame()
	else:
		Game.remainingTurns = Game.kTurnsPerHour
		hud.updateTime()
		for region in $Regions.get_children():
			region.show()
		canDoAction = true
		yield(get_tree().create_timer(0.1), "timeout")

func _unhandled_input(event: InputEvent) -> void:
	if Game.state == Game.kStateIntro:
		if Input.is_action_just_pressed("startGame"):
			emit_signal("gameStarted")
		return
	
	if canDoAction == false: return
	
	if Input.is_action_just_pressed("shootAlien"):
		shootAlien()
	elif Input.is_action_just_pressed("attackAlienSite"):
		attackAlienSite()
	elif Input.is_action_just_pressed("takeOff"):
		takeOff()
	elif Input.is_action_just_pressed("backToMenu"):
		Game.restartGame()

func refreshRegionVisuals() -> void:
	for region in $Regions.get_children():
		region.update()

func getRegionAlienCount() -> int:
	var count = 0
	for alien in get_tree().get_nodes_in_group("aliens"):
		if alien.regionId == Game.currentRegion:
			count += 1
	return count

func getBaseRegionAliensCount() -> int:
	var count = 0
	for alien in get_tree().get_nodes_in_group("aliens"):
		if alien.regionId == Game.kStartingRegion:
			count += 1
	return count

func getRandomSpawnRegion() -> Region:
	var regionId = randi() % $Regions.get_child_count() + 1
	while regionId == Game.kStartingRegion:
		regionId = randi() % $Regions.get_child_count() + 1
	return $Regions.get_node("Region" + str(regionId)) as Region

func shootAlien() -> void:
	canDoAction = false
	var aliensToKill : int = 1
	var killedAlien : bool = false
	for mapAlien in $Entities/Aliens.get_children():
		if mapAlien.regionId == Game.currentRegion and aliensToKill > 0:
			$Sounds/ShootAlien.play()
			mapAlien.kill()
			aliensToKill -= 1
			killedAlien = true
#			yield($Sounds/ShootAlien, "finished")
	if killedAlien == true:
		Game.remainingTurns -= 1
		hud.updateTime()
		if Game.remainingTurns <= 0:
			yield(endTurn(), "completed")
	else:
		yield(get_tree(), "idle_frame")
	canDoAction = true

func attackAlienSite() -> void:
	canDoAction = false
	var alienSite : AlienSite = getCurrentRegionAlienSite()
	if alienSite != null:
		var rollToAttack : int = randi() % 6 + 1
		print(rollToAttack)
#		debug
		if rollToAttack > 4:
#		if rollToAttack > 1:
			alienSite.destroy()
			yield(get_tree(), "idle_frame")
			yield(get_tree(), "idle_frame")
			if getAlienSitesCount() == 0:
				var msgText : String = "You destroyed the last of these alien structures.\n\nReturn to your ship to take off and return to Earth!"
				msgText += "Press (T) at your ship location to take off and return to Earth."
				yield(hud.msg(msgText), "completed")
			else:
				var msgText : String = "Your infiltration of the structure lead you to the a room where a large alien is (from the look of it) controling the structure.\n\nAs you shoot the large alien the structure begin to crumble. As you exit the structure you hear a scream as the structure collapsed! The large alien wasn't just controlling it....It was part of the it itself!.\n\nYou succeeded in destroying the alien structure."
				yield(hud.msg(msgText), "completed")
				if getAlienSitesCount() == 3:
					Game.spawnRate += 1
				elif getAlienSitesCount() == 2:
					Game.spawnRate += 1
		else:
			var msgText : String = "Your infiltration failed to uncover a way for you to destroy the alien structure.\n\nYou failed to destroy the alien structure."
			yield(hud.msg(msgText), "completed")
		Game.remainingTurns -= 1
		hud.updateTime()
		hud.updateObjectives()
		if Game.remainingTurns <= 0:
			yield(endTurn(), "completed")
	canDoAction = true

func takeOff() -> void:
#	debug
#	if getAlienSitesCount() > 0: return

	canDoAction = false
	var takeOffPos = landingCraft.global_position - Vector2(0, landingCraft.global_position.y + 100)
	player.hide()
	yield(get_tree().create_timer(1.5), "timeout")
	tween.interpolate_property(landingCraft, "global_position", landingCraft.global_position, takeOffPos, 2.0, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_completed")
	var msgText = "SHUTTLE 2786: Shuttle 2786 to Control. You will never believe what was causing the disturbances!\n\n"
	msgText += "CONTROL: ....\n\n"
	msgText += "SHUTTLE 2786: Control! Do you read me?\n\n"
	msgText += "CONTROL: AAAAAAAAAAAA....\n\n"
	msgText += "SHUTTLE 2786: Was that a scream I heard? Ohhh, I have a bad feeling about this!\n\n\n"
	msgText += "THE END?"
	yield(hud.msg(msgText), "completed")
	Game.restartGame()

func getCurrentRegionAlienSite() -> AlienSite:
	for alienSite in get_tree().get_nodes_in_group("alienSites"):
		if alienSite.regionId == Game.currentRegion:
			return alienSite
	return null

func getAlienSitesCount() -> int:
	return get_tree().get_nodes_in_group("alienSites").size()
