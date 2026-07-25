class_name EntityListEntry extends Resource

@export var scene: PackedScene
@export var weight := 1.0
@export_flags("1", "2", "3", "4", "5") var depths: int = (2**32) - 1
@export_range(0.0, 180.0) var max_vertical_angle := 180.0
