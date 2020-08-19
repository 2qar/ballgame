# TODO: switch to KinematicBody2D, idiot
extends RigidBody2D

signal goal_hit(pos)

export var hit_velocity : int
export(int, LAYERS_2D_PHYSICS) var still_mask
export(int, LAYERS_2D_PHYSICS) var moving_mask

onready var initial_pos = position
var reset = false

func _ready():
	collision_layer = still_mask
	collision_mask = still_mask

remotesync func hit(dir: Vector2):
	linear_velocity = dir * hit_velocity
	$trail.process_material.direction = Vector3(dir.x, dir.y, 0)
	collision_layer = moving_mask
	collision_mask = moving_mask

func _draw():
	draw_circle(Vector2(), $collider.shape.radius, Color.beige)

func _integrate_forces(state):
	if reset:
		reset_position(state)
	
	$trail.process_material.initial_velocity = state.linear_velocity.length()
	if state.linear_velocity.sign().x == 1 or state.linear_velocity.sign().y == 1:
		$trail.process_material.initial_velocity *= -1

func reset_position(state: Physics2DDirectBodyState):
	state.linear_velocity = Vector2()
	state.transform = Transform2D(0, initial_pos)
	collision_layer = still_mask
	collision_mask = still_mask
	$trail.restart()
	reset = false

func _on_ball_body_entered(body):
	if body.name == "goal":
		emit_signal("goal_hit", position)
	else:
		reset = true
