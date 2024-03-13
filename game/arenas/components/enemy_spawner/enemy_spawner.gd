extends Node


#@onready var arena = get_parent()
#@onready var available_arena_radius = arena.ARENA_RADIUS - 1
#@onready var cell_size = arena.CELL_SIZE
#@onready var player = get_parent().get_node_or_null("Player")


var current_enemy_level := 3
var enemy_counter := 3


func _on_timer_timeout():
	spawn_new_enemy()


func spawn_new_enemy():
	pass
	#var new_spawning_enemy = SpawningEnemy.new(get_enemy_level())
	#new_spawning_enemy.position = choose_position()
	#arena.add_child(new_spawning_enemy)


func get_enemy_level():
	if enemy_counter == 0:
		current_enemy_level += 1
		enemy_counter = current_enemy_level
	enemy_counter -= 1
	return current_enemy_level


func choose_position():
	pass
	#var new_enemy_position = player.position
	#var player_direction_vector = player.move_direction_vector
#
	#if randi_range(0, 1) == 0 or player_direction_vector == Vector2.ZERO:
		#new_enemy_position += Vector2.from_angle(randf_range(0.0, 2 * PI)).normalized() * 2 * cell_size
	#else:
		#new_enemy_position += player.move_direction_vector.normalized() * 2 * cell_size
#
	#if abs(new_enemy_position.x) >= available_arena_radius * cell_size or abs(new_enemy_position.y) >= available_arena_radius * cell_size:
		#return choose_position()
	#return new_enemy_position
