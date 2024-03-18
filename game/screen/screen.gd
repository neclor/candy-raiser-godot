extends Node2D


var colors = PackedColorArray([Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE])
var uvs  = PackedVector2Array([Vector2.ZERO, Vector2.DOWN, Vector2.ONE, Vector2.RIGHT])


var screen_size = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))
var screen_ratio = screen_size.x / screen_size.y


var view_angle = PI / 2
var view_angle_factor : float


var camera_position : Vector4
var screen_polygons : Array


func _ready():
	update_screen_settings()


func update_screen_settings():
	view_angle_factor = tan(view_angle / 2)


func set_view_angle(new_view_angle : float):
	view_angle = clamp(new_view_angle, PI / 3, 2 * PI / 3)
	update_screen_settings()


func _draw():
	screen_polygons.sort_custom(func(polygon_0, polygon_1): return polygon_0.distance > polygon_1.distance)
	for polygon in screen_polygons:
		draw_polygon(polygon.points, colors, uvs, polygon.texture)


func set_objects(objects : Array):
	screen_polygons.append_array(create_screen_objects_polygons(objects))


func create_screen_objects_polygons(objects : Array):
	var screen_objects_polygons := []
	var camera_position_3 = Vector3(camera_position.x, camera_position.y, camera_position.z)

	for object in objects:
		var object_position = Vector3(object.position.x, object.position.y, object.position_z)
		var relative_object_position = (object_position - camera_position_3).rotated(Vector3.BACK , -camera_position.w)

		if relative_object_position.y < 0:
			var max_distance = -relative_object_position.y

			var point_00 = relative_object_position + Vector3(-object.radius, 0, object.height)
			var point_10 = relative_object_position + Vector3(object.radius, 0, object.height)
			var point_11 = relative_object_position + Vector3(object.radius, 0, 0)
			var point_01 = relative_object_position + Vector3(-object.radius, 0, 0)
			var object_relative_points := PackedVector3Array([point_00, point_10, point_11, point_01])

			var screen_object_polygon_points := PackedVector2Array([])
			for point in object_relative_points:
				var horizontal_distance_ratio = point.x / -point.y * view_angle_factor
				var vertical_distance_ration = point.z / -point.y * screen_ratio

				screen_object_polygon_points.append(Vector2(horizontal_distance_ratio + 1, 1 - vertical_distance_ration) * (screen_size / 2))

			var screen_polygon = ScreenPolygon.new(screen_object_polygon_points, max_distance, object.sprite_2d.texture)
			screen_objects_polygons.append(screen_polygon)

	return screen_objects_polygons


func set_walls(walls : Array):
	screen_polygons.append_array(create_screen_wall_polygons(get_relative_walls(walls)))


func get_relative_walls(walls : Array):
	var relative_walls := []

	for wall in walls:
		var relative_points := PackedVector3Array([])
		var in_front := false

		for point in wall.points:
			var relative_point = (point - Vector3(camera_position.x, camera_position.y, camera_position.z)).rotated(Vector3.BACK , -camera_position.w)
			relative_points.append(relative_point)

			in_front = in_front or relative_point.y < 0

		if in_front:
			relative_walls.append(Wall3D.new(relative_points, wall.texture_key))

	return relative_walls


func create_screen_wall_polygons(relative_walls : Array):
	var screen_wall_polygons := []

	for relative_wall in relative_walls:
		var screen_wall_polygon_points := PackedVector2Array([])

		var max_distance := 0.0

		for point in relative_wall.points:
			max_distance = -point.y if max_distance < -point.y else max_distance

			var horizontal_distance_ratio = point.x / -point.y * view_angle_factor
			var vertical_distance_ration = point.z / -point.y * screen_ratio

			screen_wall_polygon_points.append(Vector2(horizontal_distance_ratio + 1, 1 - vertical_distance_ration) * (screen_size / 2))

		var screen_polygon = ScreenPolygon.new(screen_wall_polygon_points, max_distance, relative_wall.textures.get(relative_wall.texture_key))
		screen_wall_polygons.append(screen_polygon)

	return screen_wall_polygons
#endregion
