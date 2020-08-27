extends KinematicBody2D

puppet var remote_pos = Vector2()
puppet var remote_hammer_rot : float
const move_speed = 320

var hammer_rot = Vector2()

var bonked = false

func set_color(color: Color):
	$sprite.modulate = color

func set_nametag(name: String):
	$nametag.text = name

func remove_nametag():
	$nametag.queue_free()

func hit_overlapping_things():
	var nodes = $hammer/area.get_overlapping_areas()
	nodes += $hammer/area.get_overlapping_bodies()
	for node in nodes:
		if node.has_method("hit"):
			node.rpc("hit", hammer_rot)

remotesync func hit(rot: Vector2):
	if bonked:
		return
	set_physics_process(false)
	bonked = true
	$sprite.scale.y = 0.5
	yield(get_tree().create_timer(1.0), "timeout")
	$sprite.scale.y = 1
	bonked = false
	set_physics_process(true)

func _physics_process(delta):
	if is_network_master():
		if Input.is_action_just_pressed("hit"):
			hit_overlapping_things()
		
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
		
		# TODO: sync this over the network
		# TODO: flip sprite when moving left or right
		if movement.length() > 0:
			$sprite.animation = "walk"
		else:
			$sprite.animation = "idle"
	else:
		position = remote_pos
		$hammer.rotation = remote_hammer_rot
