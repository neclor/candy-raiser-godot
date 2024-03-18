class_name Enemy
extends Entity


@onready var player = get_parent().get_node_or_null("Player")
@onready var ray_cast_2d = $RayCast2D
@onready var wait_timer = $WaitTimer
@onready var attack_cooldown_timer = $AttackCooldownTimer
const RED_BULLET = preload("res://game/objects/projectiles/red_projectile/red_bullet.tscn")


enum State {
	WAIT,
	FIGHT,
	SEARCH,
}
var state := State.WAIT


var wait_speed := 25
var move_vector := Vector2.ZERO


var last_player_position : Vector2
var keep_distance := 64


var attack_cooldown := 1
var attack_ready := true


func _physics_process(_delta):
	match state:
		State.WAIT:
			wait()
		State.FIGHT:
			fight()
		State.SEARCH:
			search()


func wait():
	if check_player_in_sight():
		state = State.FIGHT
		wait_timer.stop()
		return

	if wait_timer.is_stopped():
		_on_wait_timer_timeout()
		wait_timer.start()

	move()


func _on_wait_timer_timeout():
	move_vector = Vector2.RIGHT.rotated(randf_range(-PI, PI)) * wait_speed if move_vector == Vector2.ZERO else Vector2.ZERO


func fight():
	if not check_player_in_sight():
		state = State.SEARCH
		return

	last_player_position = player.position
	var vector_to_player = last_player_position - self.position
	if keep_distance < vector_to_player.length():
		move_vector = vector_to_player.normalized() * speed
		move()


func search():
	if check_player_in_sight():
		state = State.FIGHT
		return

	if abs(last_player_position - self.position) <= Vector2(1, 1):
		state = State.WAIT
		return

	move_vector = (last_player_position - self.position).normalized() * speed
	move()


func check_player_in_sight():
	if not player:
		player = get_parent().get_node_or_null("Player")
		if not player:
			return false

	ray_cast_2d.target_position = player.position - self.position
	var collider = ray_cast_2d.get_collider()
	if collider and collider.is_in_group("player"):
		return true
	return false


func _on_attack_cooldown_timer_timeout():
	if state != State.FIGHT:
		return
	attack()


func attack():
	pass


func move():
	velocity = move_vector
	move_and_slide()



