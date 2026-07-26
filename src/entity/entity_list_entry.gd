class_name EntityListEntry extends Resource

@export var scene: PackedScene
@export var weight := 1.0
@export_range(0.0, 180.0) var max_vertical_angle := 180.0

## Formula to compute a weight factor depending on the cell.
##
## Inputs: cell_x and cell_y.
##
## Ex: cell_x * 2 + cell_y
@export var cell_weight_factor_expression: String

var _parsed_expr: Expression
var _last_expression_str := ""


func cell_weight_factor(cell: Vector2i) -> float:
	if cell_weight_factor_expression == "":
		return 1.0
	
	if _parsed_expr == null || _last_expression_str != cell_weight_factor_expression:
		_parsed_expr = Expression.new()
		if _parsed_expr.parse(cell_weight_factor_expression, PackedStringArray(["cell_x", "cell_y"])) != OK:
			push_error("Invalid expression `%s`" % cell_weight_factor_expression)
			return 1.0
		
		_last_expression_str = cell_weight_factor_expression

	var res = _parsed_expr.execute([cell.x, cell.y])
	if _parsed_expr.has_execute_failed():
		push_error("Expression failed to execute")
		return 1.0
	
	return clampf(res, 0.0, 1.0)
