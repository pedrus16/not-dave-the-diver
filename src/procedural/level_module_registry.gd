class_name LevelModuleRegistry extends Resource

@export var modules: Array[LevelModuleDescriptor]
@export var horizontal_closed_connector: PackedScene
@export var vertical_closed_connector: PackedScene

var _analyzed := false
## Array item type: LevelModuleDescriptor
var _modules_by_existing_connector: Dictionary[ModuleConnector.Location, Array]
## Modules having a top and bottom connector.
##
## Vertical modules are preferred in the center of the map.
var _vertical_modules: Array[LevelModuleDescriptor]


## Analyze all registered modules by finding all ModuleConnectors.
##
## Required to use module_by_connector_location.
func analyze() -> void:
	_modules_by_existing_connector = {}
	_vertical_modules = []
	
	for loc in ModuleConnector.ALL_LOCATIONS:
		_modules_by_existing_connector[loc] = [] as Array[LevelModuleDescriptor]
	
	for module in modules:
		module.analyze()
		
		for loc in ModuleConnector.ALL_LOCATIONS:
			if !module.connectors_by_location(loc).is_empty():
				_modules_by_existing_connector[loc].append(module)
		
		if !module.connectors_by_location(ModuleConnector.Location.UP).is_empty() \
			&& !module.connectors_by_location(ModuleConnector.Location.DOWN).is_empty():
			_vertical_modules.append(module)
	
	_analyzed = true


## Returns the list of LevelModules having at least one ModuleConnector with the given location.
func modules_by_connector_location(location: ModuleConnector.Location) -> Array[LevelModuleDescriptor]:
	if !_analyzed:
		push_error("modules_by_connector_location() called before analyze()")
		return []
	
	return _modules_by_existing_connector[location]


func vertical_modules() -> Array[LevelModuleDescriptor]:
	return _vertical_modules
