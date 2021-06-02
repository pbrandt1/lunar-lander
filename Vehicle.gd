extends Area2D

signal contact

export var gravity_acc = 1.625 * 5
export var vx_max = 2
export var vy_max = 10
export var tilt_max = 20 # deg

var velocity = Vector2()
var throttle = 0.0
var propellant = 100.0
var rotation_rate = PI / 2 # radians per second

var playing = false
var state_message = ''
var screen_size

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	hide()
	
func start_game():
	$AnimatedSprite.animation = "coast"
	velocity.y = 10
	velocity.x = 100
	throttle = 0.0
	propellant = 100.0
	position.x = 100
	position.y = 100
	playing = true
	$CollisionShape2D.set_deferred("disabled", false)
	show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# check for landed condition
	if !playing:
		return
	
	# Throttle up/down
	if Input.is_action_pressed("ui_up"):
		throttle = 1
	else:
		throttle = 0	
	
	# RCS: If both pressed, landing burn
	# If only left or right pressed, spin the vehicle
	var left_rcs = Input.is_action_pressed("ui_left")
	var right_rcs = Input.is_action_pressed("ui_right")
	var rcs_on = left_rcs || right_rcs

	# Animations
	if throttle > 0 && rcs_on:
		$AnimatedSprite.animation = "raptor_rcs"
	elif throttle > 0:
		$AnimatedSprite.animation = "raptor"
	elif rcs_on:
		$AnimatedSprite.animation = "rcs"
	else:
		$AnimatedSprite.animation = "coast"
	
	# integrate the state
	# notes for me. up / down incrememnt and decrement the raptor
	# left and right pulse the left and right rcs respectively
	if left_rcs:
		rotation -= rotation_rate * delta
	if right_rcs:
		rotation += rotation_rate * delta
	if rotation > 2 * PI:
		rotation -= 2 * PI;
	if rotation < -2 * PI:
		rotation += 2 * PI;

	position += velocity * delta
	velocity.y += gravity_acc * delta

	# Raptor thrust component
	var thrust_acc = 30 * throttle

	# RCS thrust component
	if left_rcs:
		thrust_acc += gravity_acc / 2
	if right_rcs:
		thrust_acc += gravity_acc / 2

	velocity.x += thrust_acc * sin(rotation) * delta
	velocity.y += -1 * thrust_acc * cos(rotation) * delta	


func _on_Vehicle_body_entered(_body):
	# check orientation, horizontal velocity, and vertical velocity
	var ok = true
	state_message = 'Successful Landing'
	
	if velocity.y > vy_max:
		ok = false
		state_message = 'Too Much Vertical Speed'
	elif abs(velocity.x) > vx_max:
		ok = false
		state_message = 'Too Much Horizontal Speed'
	elif abs(rotation_degrees) > 20:
		ok = false
		state_message = 'Too Much Tilt'
	
	if !ok:
		$AnimatedSprite.animation = "crashed"
		
	emit_signal("contact", ok, state_message)
		
	
	playing = false
	rotation = 0
	$CollisionShape2D.set_deferred("disabled", true)
