class_name GenerationConfig extends Resource

## Arbitrary maximum number of modules in a level.
@export_range(0, 1000, 1, "exp") var max_module_count: int = 30

## If true, modules in the horizontal center will always have top and bottom connectors.
@export var force_vertical_modules_in_center := true

## If true, connectors going upward will always be walled.
@export var avoid_up_connections := true

## Maximum module depth.
@export_range(0, 100, 1, "exp") var max_depth: int = 5

@export_group("Horizontal expansion probability")

## Center of the probability curve when limiting horizontal expansion.
##
## Corresponds to x0 parameter in https://www.desmos.com/calculator/bcq1kbygzg.
@export_range(0.0, 10.0) var horizontal_limit_probability_center := 1.4

## Slope of the probability curve when limiting horizontal expansion.
##
## Corresponds to k parameter in https://www.desmos.com/calculator/bcq1kbygzg.
@export_range(0.0, 10.0) var horizontal_limit_probability_slope := 3.0
