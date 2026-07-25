extends Node2D

signal new_game_requested
signal main_menu_requested

@export var level_generator: LevelGenerator
@export var first_connector: ModuleConnector


func _ready() -> void:
	level_generator.instantiate_level(self, first_connector, randi())


func restart_game() -> void:
	new_game_requested.emit()


func go_to_main_menu() -> void:
	main_menu_requested.emit()
