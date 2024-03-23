class_name CharacterIntegratorExample
extends Spatial

func _process(delta:float)->void :
	$Scene / Visuals / ImmediateGeometry.clear()
	$Scene / Collision / Player.integrator.draw_debug($Scene / Visuals / ImmediateGeometry, $Scene / Collision / Player.global_transform.origin)


func on_kill_volume_body_entered(body:Node)->void :
	if body == $Scene / Collision / Player:
		body.global_transform = Transform(Basis.IDENTITY, Vector3.UP * 7)


func on_draw_on_physics_tick_toggled(button_pressed:bool)->void :
	if button_pressed:
		Engine.target_fps = Engine.iterations_per_second
	else :
		Engine.target_fps = 0
