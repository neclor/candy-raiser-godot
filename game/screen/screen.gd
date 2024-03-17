extends Node2D


var view_angle = PI / 2
var vertical_angle = atan(9/16)
var view_angle_factor : float

var screen_size = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))
#var 

var polygons : Array


var colors = PackedColorArray([Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE])
var uvs  = PackedVector2Array([Vector2.ZERO, Vector2.DOWN, Vector2.ONE, Vector2.RIGHT])


var floors_screen_polygons : Array
var walls_screen_polygons : Array


func _ready():
	update_screen_settings()


func update_screen_settings():
	view_angle_factor = tan(view_angle / 2)


func set_view_angle(new_view_angle : float):
	if PI / 3 <= new_view_angle and new_view_angle <= 2 * PI / 3:
		view_angle = new_view_angle
		update_screen_settings()


func _process(_delta):
	#queue_redraw()
	pass


func _draw():
	for polygon in walls_screen_polygons:
		draw_polygon(polygon.points, colors, uvs, Polygon3D.textures.get(polygon.texture_key))



func set_floor(player_info : Dictionary, floors : Array):
	pass




func set_walls(player : Vector4, walls : Array):
	walls_screen_polygons = get_screen_polygons(player, walls)


func get_screen_polygons(player : Vector4, polygons_3d : Array):
	var relative_polygons_3d = get_relative_polygons_3d(player, polygons_3d)
	relative_polygons_3d.sort_custom(polygon_3d_distance_compare)
	var screen_polygons = create_screen_polygons(relative_polygons_3d)
	return screen_polygons


func create_screen_polygons(relative_polygons_3d : Array):
	var screen_polygons := []

	for relative_polygon_3d in relative_polygons_3d:
		var screen_polygon_points := PackedVector2Array([])

		for point in relative_polygon_3d.points:
			var y_coord = 1 if abs(point.y) < 1 else point.y
			#print(relative_polygon_3d.points)
			#print(y_coord)
			#print(point.y)
			#if y_coord
			var horizontal_distance_ratio = point.x / -y_coord * view_angle_factor
			var vertical_distance_ration = point.z / -y_coord * 16 / 9
			var screen_point = Vector2(horizontal_distance_ratio + 1, 1 - vertical_distance_ration) * (screen_size / 2)
			screen_polygon_points.append(screen_point)


		var screen_polygon = ScreenPolygon.new(screen_polygon_points, relative_polygon_3d.texture_key)
		screen_polygons.append(screen_polygon)

	return screen_polygons

func distance_to_polygon_3d(polygon_3d):
	var distance := 0.0
	for point in polygon_3d.points:
		distance = max(distance, Vector2(point.x, point.y).length())
	return distance

func polygon_3d_distance_compare(polygon_3d_0, polygon_3d_1):
	return distance_to_polygon_3d(polygon_3d_0) > distance_to_polygon_3d(polygon_3d_1)

func get_relative_polygons_3d(player : Vector4, polygons_3d : Array):
	var relative_polygons_3d := []
	var player_camera_pos = Vector3(player.x, player.y, player.z)

	for polygon_3d in polygons_3d:
		var relative_points := PackedVector3Array([])
		var in_sight := false

		for point in polygon_3d.points:
			var relative_point := Vector3(point - player_camera_pos).rotated(Vector3.BACK , -player.w)
			relative_points.append(relative_point)

			var angle_to_point = Vector2(relative_point.x, relative_point.y).angle()
			in_sight = in_sight or (-PI < angle_to_point and angle_to_point < 0)
		if in_sight:
			var relative_polygon_3d = Polygon3D.new(relative_points, polygon_3d.texture_key)
			relative_polygons_3d.append(relative_polygon_3d)

	return relative_polygons_3d
