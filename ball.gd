extends Area2D

signal goal_hit(pos)

export var hit_velocity : int
var velocity = Vector2()
export(int, LAYERS_2D_PHYSICS) var still_mask
export(int, LAYERS_2D_PHYSICS) var moving_mask

onready var initial_pos = position

func _ready():
	collision_layer = still_mask
	collision_mask = still_mask
	connect("body_entered", self, "_on_ball_body_entered")

remotesync func hit(dir: Vector2):
	velocity = dir * hit_velocity
	$trail.process_material.direction = Vector3(dir.x, dir.y, 0)
	collision_layer = moving_mask
	collision_mask = moving_mask

func _draw():
	draw_circle(Vector2(), $collider.shape.radius, Color.beige)

func _physics_process(delta):
	position += velocity

	$trail.process_material.initial_velocity = velocity.length()
	if velocity.sign().x == 1 or velocity.sign().y == 1:
		$trail.process_material.initial_velocity *= -1

func _on_ball_body_entered(body):
	if body.name == "goal":
		emit_signal("goal_hit", position)
	else:
		velocity = Vector2()
		position = initial_pos
		collision_layer = still_mask
		collision_mask = still_mask
		$trail.restart()
