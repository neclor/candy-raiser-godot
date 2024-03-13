class_name Arena
extends Node2D


@onready var player = $Player
@onready var enemy_container = $EnemyContainer
@onready var tile_map = $TileMap
@onready var cell_size = tile_map.tile_set.tile_size


var arena_height := 32+64


var roofs : Array
var walls : Array
var floors : Array


func _ready():
	floors = get_floors()
	walls = get_walls()
	walls = [walls[0]]
	update_screen()


func _process(_delta):
	update_screen()


func update_screen():
	var player_info := {
		"position" : Vector3(player.position.x, player.position.y, player.position_z),
		"height" : player.height,
		"rotation" : player.rotation,
	}
	#Screen.set_floor(player_info, floors)
	#Screen.set_roof(player_info, roofs)
	Screen.set_walls(player_info, walls)
	Screen.queue_redraw()


func get_floors():
	var new_floors := []
	var tiles = get_tiles(0)
	for tile in tiles:
		var floor = Polygon3D.new(tile[0], tile[1])
		floors.append(floor)
	return new_floors


func get_walls():
	var new_walls := []
	var tiles = get_tiles(1)
	for tile in tiles:
		var points_amount = tile[0].size()
		for i in points_amount:
			var point_00 = tile[0][i] + Vector3(0, 0, arena_height)
			var point_10 = tile[0][(i + 1) % points_amount]  + Vector3(0, 0, arena_height)
			var point_11 = tile[0][(i + 1) % points_amount]
			var point_01 = tile[0][i]

			var points = PackedVector3Array([point_00, point_10, point_11, point_01])

			var wall = Polygon3D.new(points, tile[1])
			new_walls.append(wall)
	return new_walls


func get_roofs():
	var new_roofs := []
	var tiles = get_tiles(2)
	for tile in tiles:
		var points := []
		var points_amount = tile[0].size()
		for i in points_amount:
			points.append(tile[0][i] + Vector3(0, 0, arena_height))
		var roof = Polygon3D.new(points, tile[1])
		roofs.append(roof)
	return new_roofs


func get_tiles(layer : int):
	var tiles := []
	for cell in tile_map.get_used_cells(layer):
		var texture_key = get_texture_key(layer, cell)

		var point_00 = Vector3(cell.x * cell_size.x, cell.y * cell_size.y, 0)
		var point_10 = Vector3(point_00.x + cell_size.x, point_00.y, 0)
		var point_11 = Vector3(point_00.x + cell_size.x, point_00.y + cell_size.y, 0)
		var point_01 = Vector3(point_00.x, point_00.y + cell_size.y, 0)

		var points = PackedVector3Array([point_00, point_10, point_11, point_01])

		var tile := [points, texture_key]
		tiles.append(tile)
	return tiles


func get_texture_key(layer : int, cell : Vector2i):
	var source_id = tile_map.get_cell_source_id(layer, cell)
	var cell_atlas_coords = tile_map.get_cell_atlas_coords(layer, cell)

	var texture_key = str(source_id) + "_" + str(cell_atlas_coords)

	if not Polygon3D.textures.has(texture_key):
		var source = tile_map.tile_set.get_source(source_id)
		var texture = ImageTexture.create_from_image(source.texture.get_image().get_region(source.get_tile_texture_region(cell_atlas_coords)))
		Polygon3D.textures[texture_key] = texture

	return texture_key
