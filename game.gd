extends Node

@export var world := preload("res://scenes/game_scene/world.tscn")
@export var menu = preload("res://scenes/game_scene/world.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_menu_start() -> void:
	var world_instance = world.instantiate()
	%World2D.add_child(world_instance)
	%Menu.hide()
