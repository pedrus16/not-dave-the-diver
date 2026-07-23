class_name LevelGenerator extends Node

@export var modules_registry: LevelModuleRegistry

var modules_count := 0


func _ready() -> void:
	modules_registry.analyze()


## Instantiate a new procedurally generated level, starting with the given connector.
func instantiate_level(root: Node2D, first_connector: ModuleConnector, level_seed: int) -> void:
	modules_count = 0
	
	var rng := RandomNumberGenerator.new()
	rng.seed = level_seed
	
	_connect_new_module(root, first_connector, rng)


func _connect_new_module(root: Node2D, connector: ModuleConnector, rng: RandomNumberGenerator) -> void:
	if modules_count > 30:
		_close_connector(root, connector)
		return
	
	var new_connector_location := ModuleConnector.opposite_location(connector.location)

	var candidates := modules_registry.modules_by_connector_location(new_connector_location)
	
	if candidates.is_empty():
		_close_connector(root, connector)
		return
	
	var chosen_module := candidates[rng.randi() % candidates.size()]
	var candidate_connectors := chosen_module.connectors_by_location(new_connector_location)
	var connector_index := candidate_connectors[rng.randi() % candidate_connectors.size()] as int
	
	var new_module := chosen_module.instantiate_and_connect(root, connector_index, connector)
	
	new_module.populate_entities(rng)
	
	modules_count += 1
	
	for new_connector in new_module.dangling_connectors():
		_connect_new_module(root, new_connector, rng)
	

func _close_connector(root: Node2D, connector: ModuleConnector) -> void:
	var wall := modules_registry.closed_connector.instantiate() as Node2D
	root.add_child(wall)
	
	if connector.location == ModuleConnector.Location.LEFT || connector.location == ModuleConnector.Location.RIGHT:
		wall.rotation_degrees += 90
	
	wall.global_position = connector.global_position
