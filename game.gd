extends Node

@export var world := preload("res://scenes/game_scene/world.tscn")
@export var menu = preload("res://scenes/game_scene/world.tscn")

var _world_instance: Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_menu_start() -> void:
	_start_game()


func _start_game() -> void:
	_world_instance = world.instantiate()
	_world_instance.new_game_requested.connect(_back_to_menu)
	_world_instance.main_menu_requested.connect(_back_to_menu)
	%World2D.add_child(_world_instance)
	
	await _preload_audio_streams(_world_instance)
	
	%Menu.hide()


func _back_to_menu() -> void:
	%World2D.remove_child(_world_instance)
	%Menu.show()


func _preload_audio_streams(game: Node2D) -> void:
	var canvas_layers := game.find_children("", "CanvasLayer")
	var buses: Dictionary[AudioStreamPlayer, StringName] = {}
	var was_playing: Dictionary[AudioStreamPlayer, bool] = {}

	game.visible = false
	for layer in canvas_layers:
		layer.visible = false
	
	game.set_process(PROCESS_MODE_DISABLED)
	
	for child in game.find_children("", "AudioStreamPlayer"):
		var player := child as AudioStreamPlayer
		buses[player] = player.bus
		was_playing[player] = player.playing
		player.bus = &"MuteBus"
		player.play()
	
	await get_tree().create_timer(0.2).timeout
	
	for player in buses:
		player.stop()
		player.seek(0.0)
		player.bus = buses[player]

		# autoplay and players that start themselves in _ready fire once, on
		# tree entry. Without this they stay stopped after the preload.
		if was_playing[player]:
			player.play()

	game.set_process(PROCESS_MODE_INHERIT)
	
	game.visible = true
	for layer in canvas_layers:
		layer.visible = true
	
	
