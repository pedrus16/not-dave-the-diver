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
	%Menu.hide()

func _back_to_menu() -> void:
	%World2D.remove_child(_world_instance)
	%Menu.show()
