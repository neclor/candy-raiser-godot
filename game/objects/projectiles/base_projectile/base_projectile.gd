class_name Projectile
extends CharacterBody2D


@onready var sprite_2d = $Sprite2D


var position_z := 5
var height := 6
var radius := 3


var speed = 200


var target_group : String
var damage : int


func init(new_velocity : Vector2, new_damage : int, new_target_group : String):
	velocity = new_velocity
	damage = new_damage
	target_group = new_target_group


func _physics_process(delta):
	var collision = move_and_collide(velocity * speed * delta)
	print(position)
	print(velocity)
	
	if collision and collision.get_collider().is_in_group(target_group):
		collision.take_demage(damage)
	queue_free()
