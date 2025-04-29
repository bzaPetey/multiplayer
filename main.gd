class_name Main extends Node3D

@export var port:int = 10024
@export var player_prefab:PackedScene

@onready var menu: CanvasLayer = $CanvasLayer

var peer:ENetMultiplayerPeer = ENetMultiplayerPeer.new()



func _on_btn_server_pressed() -> void:
    menu.hide()
    peer.create_server(port)
    multiplayer.multiplayer_peer = peer
#	multiplayer.peer_connected.connect(add_player)
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)

    # Spawn the server's own player
    add_player(multiplayer.get_unique_id())



func _on_btn_client_pressed() -> void:
    menu.hide()
    peer.create_client("127.0.0.1", port)
    multiplayer.multiplayer_peer = peer


#make an rpc
@rpc("authority")
func add_player(id: int) -> void:
    var player = player_prefab.instantiate() as Player
    player.name = str(id)
    player.set_multiplayer_authority(id) # << ADD THIS LINE!
    add_child(player)

#rpc() → means "send to other peers", not self.
#rpc_id(1, ...) → means "send to server (itself)" explicitly.

# Called when someone connects
func _on_peer_connected(id: int) -> void:
    if multiplayer.is_server():
        # Step 1: Server adds the player locally
        add_player(id)

        # Step 2: Tell all clients to add the new player
        add_player.rpc(id)

        # Step 3: Send all existing players to the new player
        for existing_id in multiplayer.get_peers():
            if existing_id != id:
                add_player.rpc_id(id, existing_id)



func _on_peer_disconnected(id: int) -> void:
    if multiplayer.is_server():
        # Tell everyone to remove the player
        remove_player(id)
        remove_player.rpc(id)



# Remote function to remove a player
@rpc("any_peer")
func remove_player(id: int) -> void:
    var player = get_node_or_null(str(id))
    if player:
        player.queue_free()
        
