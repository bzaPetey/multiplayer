class_name Main extends Node3D

@export var port:int = 10024
@export var player_prefab:PackedScene

@onready var menu: CanvasLayer = $CanvasLayer
@onready var player_name: TextEdit = %txtName
@onready var player_color:ColorPicker = %crColor


var peer:ENetMultiplayerPeer = ENetMultiplayerPeer.new()



# -----------------------------------------------------------------
func _on_btn_server_pressed() -> void:
	menu.hide()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	# Spawn the server's own player
	add_player(multiplayer.get_unique_id())



func _on_btn_client_pressed() -> void:
	menu.hide()
	peer.create_client("127.0.0.1", port)
	multiplayer.multiplayer_peer = peer
# -----------------------------------------------------------------



@rpc("any_peer")
func add_player(id:int) -> void:
	var player = player_prefab.instantiate() as Player
	player.name = str(id)
	player.player_name = player_name.text
	player.player_color = player_color.color
	player.set_multiplayer_authority(id)
	add_child(player)


@rpc("any_peer")
func remove_player(id:int) -> void:
	var p := get_node_or_null(str(id))
	
	if p:
		p.queue_free()
# -----------------------------------------------------------------



func _on_peer_connected(id:int) -> void:
	if multiplayer.is_server():
		#1) Spawn the new player's character for everyone
		add_player(id)			# local server
		add_player.rpc(id)		# broadcast to all peers
		
		#2) tell the newcomer to spawn the host
		var host_id: int = multiplayer.get_unique_id()
		add_player.rpc_id(id, host_id)
		
		#3) tell the newcomer about all of the already connected clients
		for existing in multiplayer.get_peers():
			if existing != id:
				add_player.rpc_id(id, existing)



func _on_peer_disconnected(id:int) -> void:
	if multiplayer.is_server():
		remove_player(id)				# remove local copy
		remove_player.rpc(id)			# remove the copy on everyone elses client
		
