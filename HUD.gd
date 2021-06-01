extends CanvasLayer

signal start_game

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func update_throttle(throttle):
	# Throttle is stored as a value between 0 and 1
	$GridContainer/ThrottleLevel.value = throttle * 100

func update_propellant(prop):
	# Propellant is stored as a percentage already
	$GridContainer/PropellantLevel.value = prop

func update_velocity(vel):
	$GridContainer/VelocityXValue.text = str(vel.x)
	$GridContainer/VelocityYValue.text = str(vel.y)

func _on_MessageTimer_timeout():
	$Message.hide()

func _on_StartButton_pressed():
	emit_signal("start_game")
	$StartButton.hide()
	$MessageTimer.start()
