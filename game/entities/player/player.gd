extends Entity


var unrotated_velocity := Vector2.ZERO


func _init():
	target_group = "enemy"
	height = 8
	speed = 125


func _draw():
	var points := PackedVector2Array([Vector2(0, -16), Vector2(10, 10), Vector2(-10, 10)])
	var colors := PackedColorArray([Color.WHITE, Color.WHITE, Color.WHITE])
	draw_polygon(points, colors)


func move():
	var input_move_direction_vector = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")).normalized()
	unrotated_velocity = Vector2.ZERO if unrotated_velocity.length() < 1 else unrotated_velocity * 0.9 #unrotated_velocity.move_toward(Vector2.ZERO, speed / 10)
	if input_move_direction_vector.x != 0:
		unrotated_velocity.x = input_move_direction_vector.x * speed
	if input_move_direction_vector.y != 0:
		unrotated_velocity.y = input_move_direction_vector.y * speed
	velocity = unrotated_velocity.rotated(rotation)
	move_and_slide()


func change_view_direction(mouse_move_x : int):
	var mouse_sensivity := 0.001
	rotation += mouse_move_x * mouse_sensivity


func _input(event):
	if event is InputEventMouseMotion:
		change_view_direction(event.relative.x)

	if Input.is_action_pressed("camera_on"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if Input.is_action_pressed("camera_off"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
