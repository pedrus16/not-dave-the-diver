extends Panel

@onready var _master_index := AudioServer.get_bus_index(&"Master")
@onready var _initial_volume := AudioServer.get_bus_volume_db(_master_index)

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	print(db_to_linear(-60.0))
	print(db_to_linear(0.0))


func _on_visibility_changed() -> void:
	var new_volume := _initial_volume
	if visible:
		new_volume -= 6.0
	
	AudioServer.set_bus_volume_db(_master_index, new_volume)
