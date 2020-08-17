extends KinematicBody2D

puppet var remote_pos = Vector2()
puppet var remote_hammer_rot : float
const move_speed = 320

var hammer_rot = Vector2()

func set_color(color: Color):
	$sprite.modulate = color

func set_nametag(name: String):
	$nametag.text = name

func remove_nametag():
	$nametag.queue_free()

func _physics_process(delta):
	if is_network_master():
		if Input.is_action_just_pressed("hit"):
			for body in $hammer/area.get_overlapping_bodies():
				if body.has_method("hit"):
					body.rpc("hit", hammer_rot)
		
		var movement = Vector2()
		if Input.is_action_pressed("left"):
			movement.x -= move_speed
			hammer_rot = Vector2(-1, 0)
		if Input.is_action_pressed("right"):
			movement.x += move_speed
			hammer_rot = Vector2(1, 0)
		if Input.is_action_pressed("up"):
			movement.y -= move_speed
			hammer_rot = Vector2(0, -1)
		if Input.is_action_pressed("down"):
			movement.y += move_speed
			hammer_rot = Vector2(0, 1)
		
		movement = move_and_slide(movement)
		rset("remote_pos", position)
		$hammer.rotation = hammer_rot.angle()
		rset("remote_hammer_rot", $hammer.rotation)
	else:
		position = remote_pos
		$hammer.rotation = remote_hammer_rot
