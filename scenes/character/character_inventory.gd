class_name CharacterInventory extends Node
## Attaches picked items to the hen.

const ROPE_SEGMENT_COUNT := 4

## Must not be child of character's moving parts.
@export var items_root: Node2D
@export var hen_rigid_body: RigidBody2D
@export var items_anchor: Node2D


func take_item(item: Node2D) -> void:
	item.reparent(items_root)

	var angle := Vector2.DOWN.angle_to(item.global_position - items_anchor.global_position)
	item.global_rotation = angle
	
	_create_rope(item)
	
	# Set item as last child, so it is displayed above the rope
	items_root.move_child(item, -1)


func _create_rope(item: Node2D) -> void:
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
