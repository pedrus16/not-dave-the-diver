extends Node2D

@export var level_generator: LevelGenerator
@export var first_connector: ModuleConnector
@export var modules_root: Node2D


func _ready() -> void:
	level_generator.instantiate_level(modules_root, first_connector, randi())
