class_name Main extends Node3D

@export var port:int = 10024
@export var player_prefab:PackedScene

@onready var menu: CanvasLayer = $CanvasLayer

var peer:ENetMultiplayerPeer = ENetMultiplayerPeer.new()



func _on_btn_server_pressed() -> void:
	menu.hide()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	add_player(multiplayer.get_unique_id())



func _on_btn_client_pressed() -> void:
	menu.hide()
	peer.create_client("127.0.0.1", port)
	multiplayer.multiplayer_peer = peer



func add_player(id:int) -> void:
	var player = player_prefab.instantiate() as Player
	player.name = str(id)
	add_child(player)
	
