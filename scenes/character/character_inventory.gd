class_name CharacterInventory extends Node
## Attaches picked items to the hen.

const ROPE_SEGMENT_COUNT := 4

## Must not be child of character's moving parts.
@export var items_root: Node2D
@export var hen_rigid_body: RigidBody2D
@export var items_anchor: Node2D

var _dragged_items: Array[ItemAndRope] = []


func take_item(item: Node2D, drop_callback: Callable) -> void:
	item.reparent(items_root)

	var angle := Vector2.DOWN.angle_to(item.global_position - items_anchor.global_position)
	item.global_rotation = angle
	
	var rope := _create_rope(item)
	
	# Set item as last child, so it is displayed above the rope
	items_root.move_child(item, -1)
	
	_dragged_items.append(ItemAndRope.new(item, rope, drop_callback))


func drop_last_item() -> void:
	var item := _dragged_items.pop_back() as ItemAndRope
	if item == null:
		return
	
	item.rope.queue_free()
	
	if item.drop_callback != null:
		item.drop_callback.call()


func on_movement_direction_change(direction: Vector2) -> void:
	var pull_strength := 3000.0
	if direction.y < 0:
		pull_strength = 300.0
	
	for item in _dragged_items:
		item.rope.anchors[0].pull_strength = pull_strength


func _create_rope(item: Node2D) -> CRope2D:
	var data := CRopeData.new()
	data.create_line_by_count(items_anchor.global_position, item.global_position, ROPE_SEGMENT_COUNT)
	
	var rope := CRope2D.new()
	rope.data = data
	
	var hen_anchor := CRopeAnchor.new()
	hen_anchor.index = 0
	hen_anchor.node_path = hen_rigid_body.get_path()
	hen_anchor.collision_resolve = false
	
	var item_anchor := CRopeAnchor.new()
	item_anchor.index = ROPE_SEGMENT_COUNT
	item_anchor.node_path = item.get_path()
	item_anchor.collision_resolve = false
	
	rope.anchors = [hen_anchor, item_anchor]
	
	# Modules
	rope.force_modules = [CRopeGravityForceMod.new()]

	var smooth = CRopeSmoothLineMod.new()
	var simplify = CRopeSimplifyLineMod.new()
	rope.line_modules = [smooth, simplify]
	
	var renderer = CRopeDirectRenderMod.new()
	renderer.width = 5.0
	renderer.color = Color.BROWN
	rope.render_modules = [renderer]

	items_root.add_child(rope)
	
	return rope


class ItemAndRope:
	var item: Node2D
	var rope: CRope2D
	var drop_callback: Callable
	
	func _init(item_: Node2D, rope_: CRope2D, drop_callback_: Callable) -> void:
		item = item_
		rope = rope_
		drop_callback = drop_callback_
