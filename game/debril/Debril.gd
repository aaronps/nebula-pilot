
extends RigidBody2D

export(bool) var explode_on_collision = false

var died = false

func _die():
	queue_free()

#return true if self destroyed
func _on_collided():
	died = true
	clear_shapes()
	get_node("Particles2D").set_initial_velocity(get_linear_velocity()/2)
	#gSoundPlayer.play("SmallExplosion")
	get_node("AnimationPlayer").play("Explode")
	return true

func _die_alone():
	died = true
	clear_shapes()
	queue_free()

func _on_Debril_body_enter( body ):
	# @note body._on_collided must be first it has to execute always
	if body._on_collided() or explode_on_collision:
		_on_collided()


