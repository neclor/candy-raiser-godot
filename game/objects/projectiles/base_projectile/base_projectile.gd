class_name Projectile
extends CharacterBody2D


@onready var sprite_2d = $Sprite2D


var position_z := 5
var height := 6
var radius := 3


var speed = 200


var target_group : String
var damage : int
var vector := Vector2.ZERO


func init(new_velocity : Vector2, new_damage : int, new_target_group : String):
	vector = new_velocity
	damage = new_damage
	target_group = new_target_group


func _physics_process(delta):
	velocity = vector * speed
	var collision = move_and_collide(vector * speed * delta)

	if collision:
		if collision.get_collider().is_in_group(target_group):
			collision.get_collider().take_damage(damage)
		queue_free()

