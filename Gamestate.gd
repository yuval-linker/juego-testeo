extends Node

const DEFAULT_PORT = 10567
const MAX_PEERS = 2 # Only 1v1

var peer = null

# Name for player
var player_name = "This Player"

var player_nodes = {}

# format id->name
var players = {}
var players_ready = []

# signals for lobby GUI
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)

# Callbacks from SceneTree

func _player_connected(id):
	rpc_id(id, "register_player", player_name)

func _player_disconnected(id):
	if has_node("/root/Level"): # Game is in progress
		if get_tree().is_network_server():
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			end_game()
	else: # Game has not started yet
		unregister_player(id)

func _connected_ok():
	emit_signal("connection_succeeded")

func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	end_game()

func _connected_fail():
	get_tree().set_network_peer(null)
	emit_signal("connection_failed")

# Lobby management functions

# remote to sync lobbies player lists
remote func register_player(new_player_name):
	var id = get_tree().get_rpc_sender_id()
	players[id] = new_player_name
	emit_signal("player_list_changed")

func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")

remote func pre_start_game(spawn_points):
	# Change Scene
	var level = load("res://Level.tscn").instance()
	get_tree().get_root().add_child(level)
	# Hide Lobby
	get_tree().get_root().get_node("Lobby").hide()
	
	var player_scene = load("res://player/Brujilda.tscn")
#	var healthHUD = level.get_node("Camera2D/HUD/PlayersHealth")
	var healthHUD = level.get_node("HUD/PlayersHealth")
	
	for p_id in spawn_points:
		var spawn_pos = level.get_node("SpawnPoints/" + str(spawn_points[p_id])).position
		var player = player_scene.instance()
		
		player.set_name(str(p_id))
		player.position = spawn_pos
		player.set_network_master(p_id)
		var this_name
		
		if p_id == get_tree().get_network_unique_id():
			this_name = player_name
		else:
			this_name = players[p_id]
		
		player.set_player_name(this_name)
		level.get_node("Players").add_child(player)
		healthHUD.add_player(player, this_name)
		player_nodes[p_id] = player
	# You can set up hud or score things here
	#
	#
	
	# Tell server we are ready to start
	if not get_tree().is_network_server():
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0: # If you are playing alone
		post_start_game()

remote func post_start_game():
	get_tree().set_pause(false)

remote func ready_to_start(id):
	assert(get_tree().is_network_server())
	
	if not id in players_ready:
		players_ready.append(id)
	
	if players_ready.size() == players.size():
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()

func host_game(new_player_name):
	player_name = new_player_name
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(peer)

func join_game(ip, new_player_name):
	player_name = new_player_name
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(peer)

func get_player_list():
	return players.values()

func get_player_name():
	return player_name

func begin_game():
	assert(get_tree().is_network_server())
	
	var spawn_points = {}
	spawn_points[1] = 0
	var spawn_point_idx = 1
	for p in players:
		spawn_points[p] = spawn_point_idx
		spawn_point_idx += 1
	
	for p in players:
		rpc_id(p, "pre_start_game", spawn_points)
	
	pre_start_game(spawn_points)

func end_game():
	if has_node("/root/Level"):
		get_node("/root/Level").queue_free()
	
	emit_signal("game_ended")
	players.clear()


func _ready() -> void:
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_player_connected")
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_connected_ok")
# warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self, "_connected_fail")
# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_server_disconnected")
