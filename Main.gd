extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

func new_game():
	$Vehicle.start_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$HUD.update_propellant($Vehicle.propellant)
	$HUD.update_throttle($Vehicle.throttle)
	$HUD.update_velocity($Vehicle.velocity)
	$HUD.update_tilt($Vehicle.rotation_degrees)

func _on_Vehicle_contact(_ok, message):
	$HUD.show_message(message)
	$StartTimer.start()
	yield($StartTimer, "timeout")
	$HUD/StartButton.show()


func _on_HUD_start_game():
	new_game()
