class_name LevelModule extends Node2D

var connectors: Array[ModuleConnector]
var interactable_spots: Array[InteractableSpot]

static var _module_connector_class_name := (ModuleConnector as Script).get_global_name()
static var _spots_class_name := (InteractableSpot as Script).get_global_name()


func _ready() -> void:
	init_entities()


func init_entities() -> void:
	for connector in find_children("", _module_connector_class_name):
		connectors.append(connector as ModuleConnector)
	
	for spot in find_children("", _spots_class_name):
		interactable_spots.append(spot as InteractableSpot)


## Connect the module to another module connector.
func connect_to(local_connector_index: int, foreign_connector: ModuleConnector) -> Error:
	if foreign_connector.connected:
		push_error("foreign_connector already connected")
		return FAILED

	if local_connector_index < 0 || connectors.size() <= local_connector_index:
		push_error("local_connector_index out of bounds: %v" % local_connector_index)
		return FAILED

	var connector := connectors[local_connector_index]
	
	if connector.connected:
		push_error("connector already connected")
		return FAILED
	
	if connector.location != ModuleConnector.opposite_location(foreign_connector.location):
		push_error("Incompatible connectors %v and %v" % [connector.location, foreign_connector.location])
		return FAILED
	
	global_position = foreign_connector.global_position - connector.global_position

	connector.connected = true
	foreign_connector.connected = true
	
	return OK


## Returns the list of connector index (from `connectors` property), that are not connected yet.
func dangling_connectors() -> Array[ModuleConnector]:
	var dangling := [] as Array[ModuleConnector]
	
	for connector in connectors:
		if !connector.connected:
			dangling.append(connector)
	
	return dangling
	

func populate_interactables(rng: RandomNumberGenerator) -> void:
	for spot in interactable_spots:
		spot.populate(rng)
