class_name LevelModuleRegistry extends Resource

@export var modules: Array[LevelModuleDescriptor]
@export var closed_connector: PackedScene

var _analyzed := false
## Array item type: LevelModule
var _modules_by_existing_connector: Dictionary[ModuleConnector.Location, Array]


## Analyze all registered modules by finding all ModuleConnectors.
##
## Required to use module_by_connector_location.
func analyze() -> void:
	_modules_by_existing_connector = {}
	
	for loc in ModuleConnector.ALL_LOCATIONS:
		_modules_by_existing_connector[loc] = [] as Array[LevelModuleDescriptor]
	
	for module in modules:
		module.analyze()
		
		for loc in ModuleConnector.ALL_LOCATIONS:
			if !module.connectors_by_location(loc).is_empty():
				_modules_by_existing_connector[loc].append(module)
	
	_analyzed = true


## Returns the list of LevelModules having at least one ModuleConnector with the given location.
func modules_by_connector_location(location: ModuleConnector.Location) -> Array[LevelModuleDescriptor]:
	if !_analyzed:
		push_error("modules_by_connector_location() called before analyze()")
		return []
	
	return _modules_by_existing_connector[location]
