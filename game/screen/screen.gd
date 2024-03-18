extends Node2D


var colors = PackedColorArray([Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE])
var uvs  = PackedVector2Array([Vector2.ZERO, Vector2.RIGHT, Vector2.ONE, Vector2.DOWN])


var screen_size = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))
var screen_ratio = screen_size.x / screen_size.y


var view_angle = TAU / 3
var view_angle_factor : float


var camera_position : Vector3
var camera_rotation : float


var screen_polygons : Array


func _ready():
	update_screen_settings()


func update_screen_settings():
	view_angle_factor = tan(view_angle / 2)


func set_view_angle(new_view_angle : float):
	view_angle = clamp(new_view_angle, PI / 3, TAU / 3)
	update_screen_settings()


func _draw():
	screen_polygons.sort_custom(func(polygon_0, polygon_1): return polygon_0.distance > polygon_1.distance)
	for polygon in screen_polygons:
		draw_polygon(polygon.points, colors, uvs, polygon.texture)


func set_camera_position(new_position : Vector3, new_rotation : float):
	camera_position = new_position
	camera_rotation = new_rotation


func set_walls(walls : Array):
	for wall in walls:
		var relative_points := PackedVector3Array([])
		var in_front := false

		for point in wall.points:
			var relative_point = (point - camera_position).rotated(Vector3.BACK , -camera_rotation)
			relative_points.append(relative_point)

			in_front = in_front or relative_point.y < 0

		if in_front:
			screen_polygons.append(create_screen_polygon(relative_points, wall.textures.get(wall.texture_key)))


func set_objects(objects : Array):
	for object in objects:
		var relative_object_position = (Vector3(object.position.x, object.position.y, object.position_z) - camera_position).rotated(Vector3.BACK , -camera_rotation)
		if relative_object_position.y >= 0:
			continue

		var point_00 = relative_object_position + Vector3(-object.radius, 0, object.height)
		var point_10 = relative_object_position + Vector3(object.radius, 0, object.height)
		var point_11 = relative_object_position + Vector3(object.radius, 0, 0)
		var point_01 = relative_object_position + Vector3(-object.radius, 0, 0)
		var relative_points := PackedVector3Array([point_00, point_10, point_11, point_01])

		screen_polygons.append(create_screen_polygon(relative_points, object.sprite_2d.texture))


func create_screen_polygon(relative_points : PackedVector3Array, texture : Texture2D):
	var screen_polygon_points := PackedVector2Array([])
	var max_distance := 0.0

	for point in relative_points:
		max_distance = -point.y if max_distance < -point.y else max_distance

		var horizontal_distance_ratio = point.x / -point.y / view_angle_factor
		var vertical_distance_ration = point.z / -point.y / (1 / screen_ratio)

		screen_polygon_points.append(Vector2(horizontal_distance_ratio + 1, 1 - vertical_distance_ration) * (screen_size / 2))

	return ScreenPolygon.new(screen_polygon_points, max_distance, texture)
