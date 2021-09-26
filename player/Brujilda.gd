extends KinematicBody2D

# Physics Constants
var GRAVITY: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var SPEED = 350
var ACCELERATION = 100
var JUMPFORCE = 400
var THROWFORCE = 600
const AIRPENALTY = 0.75

# Variables
puppet var lineal_vel = Vector2.ZERO
puppet var puppet_pos
puppet var puppet_scale = 1
puppet var _facing_right = true
var _second_jump = true
puppet var _equipped
var on_floor = true
puppet var puppet_floor = true

var twinkle = false
var potion_index = 0
var _time: float = 0.0

# Classes
var Potion = preload("res://real_potions/Potion.tscn")
var SpacePotion = preload("res://real_potions/SpacePotion.tscn")

onready var playback = $AnimationTree["parameters/playback"]
onready var direction_timer = $DirectionTimer
onready var spawner = $DirectionNode/PotionSpawn
onready var nameNode = $DirectionNode/NameNode
onready var directionNode = $DirectionNode

func _ready() -> void:
	$AnimationTree.active = true
	puppet_pos = position
	_equipped = Potion

func _physics_process(delta: float) -> void:
	# Every input
	if is_network_master():
		lineal_vel = move_and_slide(lineal_vel, Vector2.UP)
		on_floor = is_on_floor()
		var target_vel = Input.get_action_strength("right") - Input.get_action_strength("left")
		lineal_vel.x = move_toward(lineal_vel.x, target_vel * SPEED, ACCELERATION)
		if not on_floor:
			lineal_vel.x *= AIRPENALTY
		lineal_vel.y += GRAVITY * delta
		
		_second_jump = _second_jump or on_floor
		
		if on_floor and Input.is_action_just_pressed("jump"):
			lineal_vel.y = -JUMPFORCE
		elif Input.is_action_just_pressed("jump") and _second_jump:
			lineal_vel.y = -JUMPFORCE
			_second_jump = false
		
		if Input.is_action_just_pressed("change_potion"):
			_equipped = Potion if _equipped == SpacePotion else SpacePotion
		
		if Input.is_action_just_pressed("throw"):
			pass
		
		if Input.is_action_pressed("left") and not Input.is_action_pressed("right") and _facing_right and direction_timer.is_stopped():
			_facing_right = false
		if Input.is_action_pressed("right") and not Input.is_action_pressed("left") and not _facing_right and direction_timer.is_stopped():
			_facing_right = true
		
		if Input.is_action_just_pressed("throw"):
			var potion_name = get_name() + str(potion_index)
			# Mal sistema de nombre :c
			potion_index += 1 % 50
			var cursor_pos = get_global_mouse_position()
			var spawn_pos = spawner.global_position
			if cursor_pos.x < global_position.x and _facing_right:
				_facing_right = false
				spawn_pos.x -= 2*spawner.position.x
				direction_timer.start()
			if cursor_pos.x > global_position.x and not _facing_right:
				_facing_right = true
				spawn_pos.x += 2*spawner.position.x
				direction_timer.start()
			rpc("throw", potion_name, spawn_pos, cursor_pos, get_tree().get_network_unique_id())
	

		rset_unreliable("puppet_pos", position)
		rset_unreliable("lineal_vel", lineal_vel)
		rset_unreliable("_facing_right", _facing_right)
		rset_unreliable("puppet_floor", on_floor)
	else:
		position = puppet_pos
		scale.x = puppet_scale
		on_floor = puppet_floor
	
	directionNode.scale.x = 1 if _facing_right else -1
	nameNode.scale.x = directionNode.scale.x
	
	if on_floor:
		if abs(lineal_vel.x) > 10:
			playback.travel("Run")
		else:
			playback.travel("Idle")
	else:
		if lineal_vel.y <= 0:
			playback.travel("Up")
		else:
			playback.travel("Falling")

#func _physics_process(delta: float) -> void:
#	lineal_vel = move_and_slide(lineal_vel, Vector2.UP)
#	lineal_vel.y += GRAVITY * delta
#
#	var on_floor = is_on_floor()
#	var target_vel = Input.get_action_strength("right") - Input.get_action_strength("left")
#
#	# Horizontal Movement
#	lineal_vel.x = lerp(lineal_vel.x, target_vel * SPEED, 0.5)
#
#	# Jump
#	if on_floor and Input.is_action_just_pressed("jump"):
#		lineal_vel.y = -JUMPFORCE
#	elif Input.is_action_just_pressed("jump") and _second_jump:
#		lineal_vel.y = -JUMPFORCE
#		_second_jump = false
#
#	# Equip
#	if Input.is_action_just_pressed("change_potion"):
#		_equipped = Potion if _equipped == SpacePotion else SpacePotion
#
#	# Animations
#	if on_floor:
#		_second_jump = true
#		if abs(lineal_vel.x) > 10:
#			playback.travel("Run")
#		else:
#			playback.travel("Idle")
#
#		if Input.is_action_just_pressed("attack"):
#			playback.travel("Attack")
#	else:
#		lineal_vel.x *= AIRPENALTY
#		if lineal_vel.y <= 0:
#			playback.travel("Up")
#			if Input.is_action_just_pressed("attack"):
#				playback.travel("JumpAttack")
#		else:
#			playback.travel("Falling")
#			if Input.is_action_just_pressed("attack"):
#				playback.travel("FallAttack")
#
#	if Input.is_action_pressed("left") and not Input.is_action_pressed("right") and _facing_right and direction_timer.is_stopped():
#		_facing_right = false
#		scale.x = -1
#	if Input.is_action_pressed("right") and not Input.is_action_pressed("left") and not _facing_right and direction_timer.is_stopped():
#		_facing_right = true
#		scale.x = -1
#
#
#		# Throw
#	if Input.is_action_just_pressed("throw"):
#		pass
#		# throw(get_global_mouse_position())
#
#	if Input.is_action_just_pressed("drink"):
#		_drink()
#
#	if twinkle:
#		modulate = Color(1, 1, 1, 0.8 + 0.2 * cos(_time * 4))
#		_time = wrapf(_time+delta, 0, PI/2)
#	else:
#		modulate = Color(1, 1, 1, 1)
#		_time = 0.0

remotesync func throw(potion_name, spawn_pos, cursor_pos, by_who):
	var potion = _equipped.instance()
	potion.set_name(potion_name)
	potion.player = get_node("../" + str(by_who))
	potion.position = spawn_pos
	var force = (cursor_pos - spawn_pos).normalized() * THROWFORCE
	potion.throw(force)
	get_node("../..").add_child(potion)



#
#func _throw(cursor_pos: Vector2):
#	if _equipped:
#		var potion = _equipped.instance()
#		potion.player = self
#		if cursor_pos.x < global_position.x and _facing_right:
#			_facing_right = false
#			scale.x = -1
#			direction_timer.start()
#		if cursor_pos.x > global_position.x and not _facing_right:
#			_facing_right = true
#			scale.x = -1
#			direction_timer.start()
#		var spawn_pos = $PotionSpawn.global_position
#		potion.global_position = spawn_pos
#		var force =  (cursor_pos - spawn_pos).normalized() * THROWFORCE
#		potion.throw(force)
#		get_parent().add_child(potion)
#	else:
#		print("huh?")

#func _drink():
#	print("Drinking!")
#	var potion = _equipped.instance()
#	potion.player = self
#	if potion.has_method("drink"):
#		get_parent().add_child(potion)
#		potion.drink()
#	else:
#		potion.queue_free()

remotesync func drink(potion_name, by_who):
	print("Drinking!")
	var potion = _equipped.instance()
	potion.player = by_who
	potion.set_name(potion_name)
	if potion.has_method("drink"):
		get_node("../..").add_child(potion)
		potion.drink()
	else:
		potion.queue_free()

remotesync func get_hurt(dmg: int):
	print("ouch!", dmg)

master func damaged(_by_who, dmg):
	rpc("get_hurt", dmg)


func set_player_name(new_name):
	$DirectionNode/NameNode/Label.set_text(new_name)

master func _on_directionTimer_timeout() -> void:
	if Input.is_action_pressed("right") and not _facing_right:
		_facing_right = true
	if Input.is_action_pressed("left") and _facing_right:
		_facing_right = false
