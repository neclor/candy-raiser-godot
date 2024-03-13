extends Node2D


const GAME_DISTANCE_TO_SCREEN = 32 #Distance at which objects are not distorted
var view_angle = PI / 2
var vertical_angle = atan(4.5/8)
var view_angle_factor : float

var screen_size = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))


var screen_factor : float
var game_screen_size : Vector2


var polygons : Array


var colors = PackedColorArray([Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE])
var uvs  = PackedVector2Array([Vector2.ZERO, Vector2.DOWN, Vector2.ONE, Vector2.RIGHT])


var floors_screen_polygons : Array
var walls_screen_polygons : Array


func _ready():
	update_screen_settings()


func update_screen_settings():
	view_angle_factor = tan(view_angle / 2)
	screen_factor = screen_size.x / tan(view_angle / 2) / GAME_DISTANCE_TO_SCREEN
	game_screen_size = screen_size / screen_factor


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
		print(polygon.points)



func set_floor(player_info : Dictionary, floors : Array):
	pass




func set_walls(player_info : Dictionary, walls : Array):
	walls_screen_polygons = get_screen_polygons(player_info, walls)


func get_screen_polygons(player_info : Dictionary, polygons_3d : Array):
	var relative_polygons_3d = get_relative_polygons_3d(player_info, polygons_3d)
	relative_polygons_3d.sort_custom(max_distance_to_polygon_3d)
	var screen_polygons = create_screen_polygons(relative_polygons_3d)
	return screen_polygons


func create_screen_polygons(relative_polygons_3d : Array):
	var screen_polygons := []

	for relative_polygon_3d in relative_polygons_3d:
		var screen_polygon_points := PackedVector2Array([])

		for point in relative_polygon_3d.points:
			var horizontal_distance_ratio = point.x / -point.y * view_angle_factor
			var vertical_distance_ration = point.z / -point.y * 9 / 16
			var screen_point = Vector2(horizontal_distance_ratio + 1, 1 - vertical_distance_ration) * (screen_size / 2)
			screen_polygon_points.append(screen_point)


		var screen_polygon = ScreenPolygon.new(screen_polygon_points, relative_polygon_3d.texture_key)
		screen_polygons.append(screen_polygon)

	return screen_polygons


func max_distance_to_polygon_3d(polygon_3d_0, polygon_3d_1):
	var polygon_3d_0_max_distance := 0.0
	var polygon_3d_1_max_distance := 0.0

	for point in polygon_3d_0.points:
		var distance = Vector2(point.x, point.y).length()
		polygon_3d_0_max_distance = distance if distance > polygon_3d_0_max_distance else polygon_3d_0_max_distance

	for point in polygon_3d_1.points:
		var distance = Vector2(point.x, point.y).length()
		polygon_3d_1_max_distance = distance if distance > polygon_3d_1_max_distance else polygon_3d_1_max_distance

	if polygon_3d_0_max_distance > polygon_3d_1_max_distance:
		return true
	return false


func get_relative_polygons_3d(player_info : Dictionary, polygons_3d : Array):
	var relative_polygons_3d := []

	for polygon_3d in polygons_3d:
		var relative_points := PackedVector3Array([])
		var in_sight := false

		for point in polygon_3d.points:
			var player_camera_pos = player_info["position"] + Vector3(0, 0, player_info["height"])
			var relative_point := Vector3(point - player_camera_pos).rotated(Vector3.BACK , -player_info["rotation"])
			relative_points.append(relative_point)

			var angle_to_point = Vector2(relative_point.x, relative_point.y).angle()
			if not in_sight and -PI / 2 - view_angle / 2 <= angle_to_point and angle_to_point <= -PI / 2 + view_angle / 2:
				in_sight = true
		if in_sight:
			var relative_polygon_3d = Polygon3D.new(relative_points, polygon_3d.texture_key)
			relative_polygons_3d.append(relative_polygon_3d)

	return relative_polygons_3d

















#func create_wall_polygon(floor_height : int, wall_points : PackedVector2Array, wall_height : float, texture_key : String):
	#var points := PackedVector2Array([])
#
	#for point in wall_points:
#
		#var distance_ratio = GAME_DISTANCE_TO_SCREEN / -point.y
		#var game_screen_coord_x = point.x * distance_ratio + game_screen_size.x / 2
		#var game_screen_coord_y_0 = (floor_height) * distance_ratio + game_screen_size.y / 2
		#var game_screen_coord_y_1 = (floor_height + wall_height) * distance_ratio + game_screen_size.y / 2
#
		#points.append(Vector2(game_screen_coord_x, game_screen_coord_y_0) * screen_factor)
		#points.append(Vector2(game_screen_coord_x, game_screen_coord_y_1) * screen_factor)
#
	#var point_2 = points[2]
	#points[2] = points[3]
	#points[3] = point_2
#
	#var polygon = Polygon.new(points, texture_key)
	#return polygon
#
#
#func create_walls_boxes_relative_to_player_array(walls_boxes : Array, player_position : Vector2, player_rotation : float) -> Array:
	#var walls_boxes_relative_to_player := []
#
	#for wall_box in walls_boxes:
		#var points_relative_to_player := []
		#var in_sight := false
#
		#for i in wall_box.points.size():
			#points_relative_to_player.append(Vector2(wall_box.points[i] - player_position).rotated(-player_rotation))
#
			#var angle_to_point = points_relative_to_player[i].angle()
			#if not in_sight and -PI + view_angle / 2 <= angle_to_point and angle_to_point <= -view_angle / 2:
				#in_sight = true
#
		#if in_sight:
			#var wall_box_relative_to_player = WallBox.new(points_relative_to_player, wall_box.height, wall_box.texture_key)
			#walls_boxes_relative_to_player.append(wall_box_relative_to_player)
#
	#walls_boxes_relative_to_player.sort_custom(max_to_min_wall_box_distance_sort)
	#return walls_boxes_relative_to_player
#
#
#func max_to_min_wall_box_distance_sort(wall_box_0, wall_box_1):
	#var wall_box_0_max_distance := 0.0
	#var wall_box_1_max_distance := 0.0
	#for point in wall_box_0.points:
		#var point_distance = point.length()
		#wall_box_0_max_distance = point_distance if point_distance > wall_box_0_max_distance else wall_box_0_max_distance
	#for point in wall_box_1.points:
		#var point_distance = point.length()
		#wall_box_1_max_distance = point_distance if point_distance > wall_box_1_max_distance else wall_box_1_max_distance
	#if wall_box_0_max_distance > wall_box_1_max_distance:
		#return true
	#return false

