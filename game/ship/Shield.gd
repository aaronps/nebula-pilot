
extends KinematicBody2D

onready var animationplayer = get_node("AnimationPlayer")

onready var COL_MASK = get_collision_mask()
onready var LAYER_MASK = get_layer_mask()
#onready var shieldShape = get_shape(0)

#shall return true if this object is destroyed by collision
func _on_collided():
	# have to check for hidden otherwise the sound will always sound, was a bug in 1.0.2
	if !is_hidden():
		gSoundPlayer.play("shield-hit")
		if animationplayer.is_playing():
			animationplayer.seek(0, false)
		else:
			animationplayer.play("hitted")
		
		return false
	
	return false

# the trigger method doesn't work good, have to remove both masks, another would be to remove the shape
# but in that case maybe the shape is not cleared... @todo check this

func disable():
	hide()
#	remove_shape(0)
#	set_shape_as_trigger(0, true)

	set_collision_mask(0)
	set_layer_mask(0)

func enable():
	show()
#	add_shape(shieldShape)
#	set_shape_as_trigger(0, false)

	set_collision_mask(COL_MASK)
	set_layer_mask(LAYER_MASK)
