extends Node2D

@export var level_generator: LevelGenerator
@export var first_connector: ModuleConnector


func _ready() -> void:
	level_generator.instantiate_level(self, first_connector, randi())
