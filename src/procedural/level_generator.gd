class_name LevelGenerator extends Node

@export var modules_registry: LevelModuleRegistry

var _first_connector_pos: Vector2
var _dangling_connectors_by_depth: Dictionary[int, Array] = {} # Array[ConnectorInfo]
var _existing_module_cells: Dictionary[Vector2i, bool] = {}


func _ready() -> void:
	modules_registry.analyze()


## Instantiate a new procedurally generated level, starting with the given connector.
func instantiate_level(root: Node2D, first_connector: ModuleConnector, level_seed: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = level_seed
	
	_first_connector_pos = first_connector.global_position
	
	var current_connector := ConnectorInfo.new(first_connector, Vector2i(0, 0))
	
	while current_connector != null:
		_connect_new_module(root, current_connector, rng)
		current_connector = _next_connector()


## Finds the next connector to connect.
func _next_connector() -> ConnectorInfo:
	if _dangling_connectors_by_depth.is_empty():
		return null

	_dangling_connectors_by_depth.sort()

	var depth := _dangling_connectors_by_depth.keys()[0] as int
	
	var connector := _dangling_connectors_by_depth[depth].pop_front() as ConnectorInfo
	
	if _dangling_connectors_by_depth[depth].is_empty():
		_dangling_connectors_by_depth.erase(depth)
	
	return connector


func _connect_new_module(root: Node2D, info: ConnectorInfo, rng: RandomNumberGenerator) -> void:
	if _should_close_connector(info, rng):
		_close_connector(root, info.connector)
		return
	
	var new_connector_location := ModuleConnector.opposite_location(info.connector.location)
	
	var candidates: Array[LevelModuleDescriptor]
	
	if _should_force_vertical_module(info):
		candidates = modules_registry.vertical_modules()
	else:
		candidates = modules_registry.modules_by_connector_location(new_connector_location)
	
	if candidates.is_empty():
		_close_connector(root, info.connector)
		return
	
	var chosen_module := candidates[rng.randi() % candidates.size()]
	var candidate_connectors := chosen_module.connectors_by_location(new_connector_location)
	var connector_index := candidate_connectors[rng.randi() % candidate_connectors.size()] as int
	
	var new_module := chosen_module.instantiate_and_connect(root, connector_index, info.connector)
	
	new_module.populate_entities(rng)
	
	_existing_module_cells[info.module_cell] = true
	
	_append_new_connectors(new_module, info.module_cell)


## Returns true if the generator should close the connector (i.e. add a wall instead of a module).
##
## Connectors horizontally far from the center are more likely to be closed, to favorise vertical exploration.
func _should_close_connector(info: ConnectorInfo, rng: RandomNumberGenerator) -> bool:
	# Security: avoid infinite recursion with arbitrary max modules count
	if _existing_module_cells.size() > 30:
		return true
	
	# Avoid modules to overlap
	if _existing_module_cells.has(info.module_cell):
		return true
	
	# Avoid modules to go up
	if info.connector.location == ModuleConnector.Location.UP:
		return true

	# Avoid modules to go to far (left/right) and to deep
	return _should_close_connector_from_x(info.module_cell, rng) \
		|| _should_close_connector_from_y(info.module_cell)


func _should_close_connector_from_x(new_module_cell: Vector2i, rng: RandomNumberGenerator) -> bool:
	if new_module_cell.x == 0:
		return false
	
	var x := absf(new_module_cell.x)
	
	x += maxf(0, 2 - new_module_cell.y)
	
	# TODO: les mettre en params
	var x0 := 1.4
	var k := 3.0
	
	# https://www.desmos.com/calculator/c1rw20yjis
	var probability := 1 / (1 + exp(-k * (x - x0)))
	
	return rng.randf() < probability


func _should_close_connector_from_y(new_module_cell: Vector2i) -> bool:
	return new_module_cell.y > 5


## We force vertical modules in the center, if the connector is either UP or DOWN.
func _should_force_vertical_module(info: ConnectorInfo) -> bool:
	if !ModuleConnector.is_location_vertical(info.connector.location):
		return false
	
	return info.module_cell.x == 0


## Add new connectors to _dangling_connectors_by_depth.
func _append_new_connectors(module: LevelModule, module_cell: Vector2i) -> void:
	for new_connector in module.dangling_connectors():
		var info := ConnectorInfo.new(new_connector, _compute_next_cell(new_connector, module_cell))
		
		if !_dangling_connectors_by_depth.has(info.module_cell.y):
			_dangling_connectors_by_depth[info.module_cell.y] = [info]
			_dangling_connectors_by_depth.sort()
		else:
			_dangling_connectors_by_depth[info.module_cell.y].append(info)


## Returns the cell of the module that would be connected to the given connector.
func _compute_next_cell(connector: ModuleConnector, current_cell: Vector2i) -> Vector2i:
	var delta: Vector2i
	
	match connector.location:
		ModuleConnector.Location.UP:
			delta = Vector2i(0, -1)
		ModuleConnector.Location.DOWN:
			delta = Vector2i(0, 1)
		ModuleConnector.Location.LEFT:
			delta = Vector2i(-1, 0)
		ModuleConnector.Location.RIGHT:
			delta = Vector2i(1, 0)
		
	return current_cell + delta


## Connect a wall to the given connector.
func _close_connector(root: Node2D, connector: ModuleConnector) -> void:
	var wall := modules_registry.closed_connector.instantiate() as Node2D
	root.add_child(wall)
	
	if connector.location == ModuleConnector.Location.LEFT || connector.location == ModuleConnector.Location.RIGHT:
		wall.rotation_degrees += 90
	
	wall.global_position = connector.global_position


class ConnectorInfo:
	## The cell of the module that would be connected to connector
	var module_cell: Vector2i
	var connector: ModuleConnector
	
	func _init(connector_: ModuleConnector, module_cell_: Vector2i) -> void:
		connector = connector_
		module_cell = module_cell_
