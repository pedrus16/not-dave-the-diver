class_name LevelGenerator extends Node

@export var config: GenerationConfig
@export var modules_registry: LevelModuleRegistry

var _first_connector_pos: Vector2
var _dangling_connectors_by_depth: Dictionary[int, Array] # Array[ConnectorInfo]
var _existing_modules: Dictionary[Vector2i, LevelModule]


func _ready() -> void:
	if config == null:
		push_warning("GenerationConfig is null. Will use default values.")
		config = GenerationConfig.new()
	
	modules_registry.analyze()


## Instantiate a new procedurally generated level, starting with the given connector.
func instantiate_level(root: Node2D, first_connector: ModuleConnector, level_seed: int) -> void:
	# Reinit member variables
	_first_connector_pos = first_connector.global_position
	_dangling_connectors_by_depth = {}
	_existing_modules = {}
	
	var rng := RandomNumberGenerator.new()
	rng.seed = level_seed
	
	
	var current_connector := ConnectorInfo.new(first_connector, Vector2i(0, 0))
	
	while current_connector != null:
		_connect_new_module(root, current_connector, rng)
		current_connector = _next_connector()
	
	_place_egg(rng)


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


## Attempt to connect a new module by using the given connector.
func _connect_new_module(root: Node2D, info: ConnectorInfo, rng: RandomNumberGenerator) -> void:
	if _should_close_connector(info, rng):
		_close_connector(root, info.connector)
		return
	
	var new_connector_location := ModuleConnector.opposite_location(info.connector.location)
	
	var candidates: Array[LevelModuleDescriptor]
	
	if _should_force_vertical_module(info):
		candidates = modules_registry.vertical_modules()
		
		# Avoid exclusively vertical levels
		if info.module_cell.y >= 2:
			candidates = candidates.filter(
				func(module: LevelModuleDescriptor) -> bool:
					return module.has_connecter_at(ModuleConnector.Location.LEFT) || module.has_connecter_at(ModuleConnector.Location.RIGHT)
			)
	else:
		candidates = modules_registry.modules_by_connector_location(new_connector_location)
	
	if candidates.is_empty():
		_close_connector(root, info.connector)
		return
	
	var chosen_module := candidates[rng.randi() % candidates.size()]
	var candidate_connectors := chosen_module.connectors_by_location(new_connector_location)
	var connector_index := candidate_connectors[rng.randi() % candidate_connectors.size()] as int
	
	var new_module := chosen_module.instantiate_and_connect(root, connector_index, info.connector)
	
	new_module.populate_entities(info.module_cell, rng)
	
	_existing_modules[info.module_cell] = new_module
	
	_append_new_connectors(new_module, info.module_cell)


## Place the unique egg in one of the deepest EntitySlots.
func _place_egg(rng: RandomNumberGenerator) -> void:
	var max_depth := -1
	var deepest_spots: Array[EntitySpot] = []
	var deepest_spots_vertical: Array[EntitySpot] = []
	
	for cell in _existing_modules:
		var module := _existing_modules[cell]
		
		# Ignore module if it doesn't have an EntitySpot
		if module.entity_spots.is_empty():
			continue
		
		if cell.y < max_depth:
			continue
		
		if cell.y > max_depth:
			# Reset the array: we found a deeper module
			deepest_spots = []
			max_depth = cell.y
		
		for spot in module.entity_spots:
			if spot.can_hold_egg:
				if cell.x == 0:
					deepest_spots_vertical.append(spot)
				else:
					deepest_spots.append(spot)
	
	var spots_to_use := deepest_spots
	if spots_to_use.is_empty():
		spots_to_use = deepest_spots_vertical
	
	if spots_to_use.is_empty():
		push_error("Cannot place the egg: there are no spots in the level")
		return
	
	var chosen_spot := spots_to_use[rng.randi() % spots_to_use.size()]
	chosen_spot.spawn_entity(config.egg_scene)


## Returns true if the generator should close the connector (i.e. add a wall instead of a module).
##
## Connectors horizontally far from the center are more likely to be closed, to favorise vertical exploration.
func _should_close_connector(info: ConnectorInfo, rng: RandomNumberGenerator) -> bool:
	# Security: avoid infinite recursion with arbitrary max modules count
	if _existing_modules.size() > config.max_module_count:
		return true
	
	# Avoid modules to overlap
	if _existing_modules.has(info.module_cell):
		return true
	
	# Avoid modules to go above the surface
	if info.module_cell.y < 0:
		return true
	
	# Only first module can be at depth 0
	if info.module_cell.y == 0 && info.module_cell.x != 0:
		return true
	
	# Avoid modules to go up
	if config.avoid_up_connections && info.connector.location == ModuleConnector.Location.UP:
		return true

	# Avoid modules to go to far (left/right) and to deep
	return _should_close_connector_from_x(info.module_cell, rng) \
		|| _should_close_connector_from_y(info.module_cell)


func _should_close_connector_from_x(new_module_cell: Vector2i, rng: RandomNumberGenerator) -> bool:
	if new_module_cell.x == 0:
		return false
	
	var x := absf(new_module_cell.x)
	
	x += maxf(0, 2 - new_module_cell.y)
	
	var x0 := config.horizontal_limit_probability_center
	var k := config.horizontal_limit_probability_slope
	
	# https://www.desmos.com/calculator/c1rw20yjis
	var probability := 1 / (1 + exp(-k * (x - x0)))
	
	return rng.randf() < probability


func _should_close_connector_from_y(new_module_cell: Vector2i) -> bool:
	return new_module_cell.y > config.max_depth


## We force vertical modules in the center, if the connector is either UP or DOWN.
func _should_force_vertical_module(info: ConnectorInfo) -> bool:
	if !config.force_vertical_modules_in_center:
		return false
	
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
	var wall: Node2D
	
	if ModuleConnector.is_location_vertical(connector.location):
		wall = modules_registry.vertical_closed_connector.instantiate() as Node2D
	else:
		wall = modules_registry.horizontal_closed_connector.instantiate() as Node2D

	root.add_child(wall)
	
	wall.global_position = connector.global_position


class ConnectorInfo:
	## The cell of the module that would be connected to connector
	var module_cell: Vector2i
	var connector: ModuleConnector
	
	func _init(connector_: ModuleConnector, module_cell_: Vector2i) -> void:
		connector = connector_
		module_cell = module_cell_
