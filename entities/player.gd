extends CharacterBody2D

signal done_walking

@export var speed = 50
@export var run_speed = 100
@export var max_stam = 100
@export var stam_consumption = 100
@export var stam_regen = 50
@export var win_walk_speed = 25

@onready var sprite = $Sprite2D
@onready var stam_bar = $Sprite2D/ProgressBar
@onready var nav = $NavigationAgent2D

var curr_stam = max_stam
var exhausted = false # for preventing running immediately after stam is 0
var interactables = []

# states
enum {
	STATE_IDLE,
	STATE_WALK,
	STATE_RUN,
	STATE_WIN
}
var curr_state = STATE_IDLE

func _ready():
	nav.target_position = position + Vector2(0, 16)

func handle_input():
	match curr_state:
		STATE_IDLE:
			if Input.is_action_just_released("run"):
				exhausted = false
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
			var input_dir = Input.get_vector("left", "right", "up", "down")
			if input_dir != Vector2.ZERO:
				if input_dir.x > 0:
					sprite.flip_h = false
				elif input_dir.x < 0:
					sprite.flip_h = true
				if Input.is_action_pressed("run") and curr_stam > 0 and not exhausted:
					velocity = input_dir * run_speed
					transition_state(STATE_RUN)
				else:
					velocity = input_dir * speed
				return # return to not transition to idle
			# idle state if no key pressed
			transition_state(STATE_IDLE)
		STATE_RUN:
			var input_dir = Input.get_vector("left", "right", "up", "down")
			if input_dir != Vector2.ZERO:
				if input_dir.x > 0:
					sprite.flip_h = false
				elif input_dir.x < 0:
					sprite.flip_h = true
				if Input.is_action_pressed("run") and curr_stam > 0:
					velocity = input_dir * run_speed
				else:
					velocity = input_dir * speed
					transition_state(STATE_WALK)
				return # return to not transition to idle
			# idle state if no key pressed
			transition_state(STATE_IDLE)

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
		STATE_WIN:
			curr_stam += stam_regen * delta
			var direction = position.direction_to(nav.get_next_path_position() - Vector2(0, 12))
			if direction.x > 0:
				sprite.flip_h = false
			elif direction.x < 0:
				sprite.flip_h = true
			velocity = direction  * win_walk_speed
			move_and_slide()
	curr_stam = clamp(snapped(curr_stam, 0.01), 0, max_stam)
	
	stam_bar.value = curr_stam

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
	
	# enter
	match state_to:
		STATE_IDLE:
			sprite.play("idle")
		STATE_WALK:
			sprite.play("run")
		STATE_RUN:
			sprite.play("run")
		STATE_WIN:
			sprite.play("win")
	curr_state = state_to


func _on_progress_bar_value_changed(value):
	if value == stam_bar.max_value:
		exhausted = false
		stam_bar.visible = false
	else:
		stam_bar.visible = true


func _on_scan_area_area_entered(area):
	if area.is_in_group("cat"):
		interactables.append(area)
		area.set_can_be_picked(true)


func _on_scan_area_area_exited(area):
	if area.is_in_group("cat"):
		interactables.erase(area)
		area.set_can_be_picked(false)


func _on_scan_area_body_entered(body):
	if body.is_in_group("hide_spot"):
		interactables.append(body)
		body.set_can_be_picked(true)


func _on_scan_area_body_exited(body: Node2D):
	if body.is_in_group("hide_spot"):
		interactables.erase(body)
		body.set_can_be_picked(false)

func game_over(_close_enc, _hover, _dodge):
	transition_state(STATE_WIN)


func _on_navigation_agent_2d_navigation_finished():
	visible = false
	emit_signal("done_walking")
