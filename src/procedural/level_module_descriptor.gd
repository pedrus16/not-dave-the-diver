class_name LevelModuleDescriptor extends Resource

@export var scene: PackedScene
@export_flags("1", "2", "3", "4", "5") var appear_in_depths: int = (2**32)-1

# Actual type: Dictionary[ModuleConnector.Location, Array[int]]
# int being the index of the connector
var _connectors: Dictionary[ModuleConnector.Location, Array] = {}


## Instantiates the module, connecting it to the given connector.
func instantiate_and_connect(root: Node2D, connector_index: int, connect_to: ModuleConnector) -> LevelModule:
	var module := scene.instantiate() as LevelModule
	root.add_child(module)
	
	if module.connect_to(connector_index, connect_to) != OK:
		module.free()
		return null

	return module


## Analyze the module, which means finding all connectors and storing them in _connectors.
##
## root is a temporary node used to instantiate then free the module.
func analyze() -> void:
	var module := scene.instantiate() as LevelModule
	module.init_connectors()
	
	for i in module.connectors.size():
		var connector := module.connectors[i] as ModuleConnector
		
		if _connectors.has(connector.location):
			_connectors[connector.location].append(i)
		else:
			_connectors[connector.location] = [i]
	
	module.free()


func connectors_by_location(location: ModuleConnector.Location) -> Array: # Array[int]
	if !_connectors.has(location):
		return []
	
	return _connectors[location]
	
