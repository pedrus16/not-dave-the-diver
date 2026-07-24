extends Node2D

@export var level_generator: LevelGenerator
@export var first_connector: ModuleConnector

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_generator.instantiate_level(self, first_connector, randi())
