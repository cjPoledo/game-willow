extends CharacterBody2D

@export var speed = 300
@export var run_speed = 900
@export var max_stam = 100
@export var stam_consumption = 100
@export var stam_regen = 50

var curr_stam = max_stam
var exhausted = false # for preventing running immediately after stam is 0
var interact_lock = false # for preventing movement when just interacted
var can_interact = false
var interacted_object = null

# states
enum {
	STATE_IDLE,
	STATE_WALK,
	STATE_RUN,
	STATE_INTERACT
}
# debugging purposes, delete later
enum states {
	STATE_IDLE,
	STATE_WALK,
	STATE_RUN,
	STATE_INTERACT
}
var curr_state = STATE_IDLE

func handle_input():
	match curr_state:
		STATE_IDLE:
			if Input.is_action_just_released("run"):
				exhausted = false
			if Input.is_action_just_pressed("interact") and can_interact:
				transition_state(STATE_INTERACT)
				return # to not execute the code below
			var input_dir = Input.get_vector("left", "right", "up", "down")
			if input_dir != Vector2.ZERO:
				if Input.is_action_pressed("run") and curr_stam > 0 and not exhausted:
					velocity = input_dir * run_speed
					transition_state(STATE_RUN)
				else:
					velocity = input_dir * speed
					transition_state(STATE_WALK)
		STATE_WALK:
			if Input.is_action_just_released("run"):
				exhausted = false
			if Input.is_action_just_pressed("interact") and can_interact:
				transition_state(STATE_INTERACT)
				return # to not execute the code below
			var input_dir = Input.get_vector("left", "right", "up", "down")
			if input_dir != Vector2.ZERO:
				if Input.is_action_pressed("run") and curr_stam > 0 and not exhausted:
					velocity = input_dir * run_speed
					transition_state(STATE_RUN)
				else:
					velocity = input_dir * speed
				return # return to not transition to idle
			# idle state if no key pressed
			transition_state(STATE_IDLE)
		STATE_RUN:
			if Input.is_action_just_pressed("interact") and can_interact:
				transition_state(STATE_INTERACT)
				return # to not execute the code below
			var input_dir = Input.get_vector("left", "right", "up", "down")
			if input_dir != Vector2.ZERO:
				if Input.is_action_pressed("run") and curr_stam > 0:
					velocity = input_dir * run_speed
				else:
					velocity = input_dir * speed
					transition_state(STATE_WALK)
				return # return to not transition to idle
			# idle state if no key pressed
			transition_state(STATE_IDLE)
		STATE_INTERACT:
			if not can_interact:
				transition_state(STATE_IDLE)
				return
			if interact_lock and Input.is_action_just_pressed("up") \
				or Input.is_action_just_pressed("down") \
				or Input.is_action_just_pressed("left") \
				or Input.is_action_just_pressed("right"):
				interact_lock = false
			if not interact_lock:
				var input_dir = Input.get_vector("left", "right", "up", "down")
				if input_dir != Vector2.ZERO:
					if Input.is_action_pressed("run") and curr_stam > 0:
						velocity = input_dir * run_speed
						transition_state(STATE_RUN)
					else:
						velocity = input_dir * speed
						transition_state(STATE_WALK)

func _physics_process(delta):
	handle_input()
	match curr_state:
		STATE_IDLE:
			curr_stam += stam_regen * delta
		STATE_WALK:
			move_and_slide()
			curr_stam += stam_regen * delta
		STATE_RUN:
			curr_stam -= stam_consumption * delta
			move_and_slide()
		STATE_INTERACT:
			curr_stam += stam_regen * delta
	curr_stam = clamp(snapped(curr_stam, 0.01), 0, max_stam)
	
	$Sprite2D/Label.text = str(states.keys()[curr_state])
	$Sprite2D/ProgressBar.value = curr_stam

func transition_state(state_to):
	# exit
	match curr_state:
		STATE_IDLE:
			pass
		STATE_WALK:
			pass
		STATE_RUN:
			if curr_stam == 0:
				exhausted = true
		STATE_INTERACT:
			if can_interact:
				interacted_object.interact(false)
	
	# enter
	match state_to:
		STATE_IDLE:
			pass
		STATE_WALK:
			pass
		STATE_RUN:
			pass
		STATE_INTERACT:
			interacted_object.interact(true)
			interact_lock = true
	curr_state = state_to

func set_can_interact(value, object):
	can_interact = value
	$Sprite2D/Label2.visible = value
	interacted_object = object


func _on_progress_bar_value_changed(value):
	if value == $Sprite2D/ProgressBar.max_value:
		exhausted = false
