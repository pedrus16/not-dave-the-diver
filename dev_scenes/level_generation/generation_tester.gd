extends Node2D

@export var generator: LevelGenerator
@export var first_connector: ModuleConnector

var _root: Node2D


func _ready() -> void:
	_generate()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey && event.is_pressed() && event.keycode == Key.KEY_SPACE:
		_generate()


func _generate() -> void:
	if _root != null:
		_root.queue_free()
		first_connector.connected = false
	
	_root = Node2D.new()
	add_child(_root)
	
	generator.instantiate_level(_root, first_connector, randi())
