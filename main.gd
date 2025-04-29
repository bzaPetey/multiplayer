class_name Main extends Node3D

@export var port:int = 10024
@export var player_prefab:PackedScene

@onready var menu: CanvasLayer = $CanvasLayer

var peer:ENetMultiplayerPeer = ENetMultiplayerPeer.new()


# ---------------------------------------------------------------------------
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
# ---------------------------------------------------------------------------

#make an rpc
@rpc("any_peer") 
func add_player(id: int) -> void:
	var player = player_prefab.instantiate() as Player
	player.name = str(id)
	player.set_multiplayer_authority(id)
	add_child(player)



@rpc("any_peer")
func remove_player(id : int) -> void:
	var p := get_node_or_null(str(id))

	if p:
		p.queue_free()
# ---------------------------------------------------------------------------



func _on_peer_connected(id : int) -> void:
	if multiplayer.is_server():
		# 1) Spawn the new player's character for everyone
		add_player(id)            # local on server
		add_player.rpc(id)        # broadcast to all peers
		
		# 2) Tell the newcomer to spawn the host
		var host_id := multiplayer.get_unique_id()  # usually 1
		add_player.rpc_id(id, host_id)
		
		# 3) Tell the newcomer about every other already-connected client		
		for existing in multiplayer.get_peers():
			if existing != id:
				add_player.rpc_id(id, existing)

func _on_peer_disconnected(id : int) -> void:
	if multiplayer.is_server():
		remove_player(id)         # local
		remove_player.rpc(id)     # everybody else
