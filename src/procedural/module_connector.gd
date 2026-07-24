class_name ModuleConnector extends Area2D

## The location of the module in the module.
##
## It is useful when connecting modules: for example, an UP connector is linked to a DOWN connector from another module.
@export var location: Location

var connected := false

const ALL_LOCATIONS := [Location.UP, Location.DOWN, Location.LEFT, Location.RIGHT]


enum Location {
	UP,
	DOWN,
	LEFT,
	RIGHT
}


static func opposite_location(loc: Location) -> Location:
	match loc:
		Location.UP:
			return Location.DOWN
		Location.DOWN:
			return Location.UP
		Location.LEFT:
			return Location.RIGHT
		Location.RIGHT:
			return Location.LEFT
		_:
			push_error("Unexpected Location value %v" % loc)
			return Location.UP


static func is_location_vertical(loc: Location) -> bool:
	return loc == Location.UP || loc == Location.DOWN
