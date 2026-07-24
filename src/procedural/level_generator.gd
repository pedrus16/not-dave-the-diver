class_name LevelGenerator extends Node

@export var modules_registry: LevelModuleRegistry

var c := 0
var _first_connector_pos: Vector2

func _ready() -> void:
	modules_registry.analyze()


## Instantiate a new procedurally generated level, starting with the given connector.
func instantiate_level(root: Node2D, first_connector: ModuleConnector, level_seed: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = level_seed
	
	_first_connector_pos = first_connector.global_position
	
	_connect_new_module(root, first_connector, rng)


func _connect_new_module(root: Node2D, connector: ModuleConnector, rng: RandomNumberGenerator) -> void:
	if _should_close_connector(connector, rng) || c > 30:
		_close_connector(root, connector)
		return
	
	var new_connector_location := ModuleConnector.opposite_location(connector.location)

	var candidates: Array[LevelModuleDescriptor]
	
	if _should_force_vertical_module(connector):
		candidates = modules_registry.vertical_modules()
	else:
		candidates = modules_registry.modules_by_connector_location(new_connector_location)
	
	if candidates.is_empty():
		_close_connector(root, connector)
		return
	
	var chosen_module := candidates[rng.randi() % candidates.size()]
	var candidate_connectors := chosen_module.connectors_by_location(new_connector_location)
	var connector_index := candidate_connectors[rng.randi() % candidate_connectors.size()] as int
	
	var new_module := chosen_module.instantiate_and_connect(root, connector_index, connector)
	c+=1
	
	new_module.populate_entities(rng)
	
	for new_connector in new_module.dangling_connectors():
		_connect_new_module(root, new_connector, rng)


## Returns true if the generator should close the connector (i.e. add a wall instead of a module).
##
## Connectors horizontally far from the center are more likely to be closed, to favorise vertical exploration.
func _should_close_connector(connector: ModuleConnector, rng: RandomNumberGenerator) -> bool:
	var connector_pos := connector.global_position - _first_connector_pos
	
	return connector.location == ModuleConnector.Location.UP \
		|| _should_close_connector_from_x(connector_pos, rng) \
		|| _should_close_connector_from_y(connector_pos)


func _should_close_connector_from_x(connector_pos: Vector2, rng: RandomNumberGenerator) -> bool:
	var x := absf(connector_pos.x) / 1920.0
	
	if x < 0.5:
		return false
	
	# TODO: les mettre en params
	var k := 5.6
	var x0 := 1.8
	
	# https://www.desmos.com/calculator/c1rw20yjis
	var probability := 1 / (1 + exp(-k * (x - x0)))
	
	return rng.randf() < probability


func _should_close_connector_from_y(connector_pos: Vector2) -> bool:
	var x := absf(connector_pos.y) / 1080.0
	
	return x > 5


func _should_force_vertical_module(connector: ModuleConnector) -> bool:
	if connector.location != ModuleConnector.Location.UP && connector.location != ModuleConnector.Location.DOWN:
		return false
	
	return abs(connector.global_position.x - _first_connector_pos.x) < 1920.0/2


## Connect a wall to the given connector.
func _close_connector(root: Node2D, connector: ModuleConnector) -> void:
	var wall := modules_registry.closed_connector.instantiate() as Node2D
	root.add_child(wall)
	
	if connector.location == ModuleConnector.Location.LEFT || connector.location == ModuleConnector.Location.RIGHT:
		wall.rotation_degrees += 90
	
	wall.global_position = connector.global_position
