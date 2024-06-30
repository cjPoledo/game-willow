extends CanvasLayer

var time = 0
var started = false

@onready var time_label = $HBoxContainer/Time
@onready var game_time_container = $HBoxContainer
@onready var game_over_screen = $GameOver
@onready var final_score_label = $GameOver/VBoxContainer/HBoxContainer5/Label3
@onready var almost_caught_label = $GameOver/VBoxContainer/HBoxContainer2/AlmostCaught2
@onready var close_enc_label = $GameOver/VBoxContainer/HBoxContainer3/CloseEncounter2
@onready var hide_label = $GameOver/VBoxContainer/HBoxContainer/Hid2
@onready var dodge_label = $GameOver/VBoxContainer/HBoxContainer4/Dodges2

func _process(delta):
	if started:
		time += delta
		time_label.text = str(round(time))

func game_over(hid, hover, dodge):
	started = false
	game_time_container.visible = false
	final_score_label.text = str(snapped(time, 0.01))
	almost_caught_label.text = str(hover + dodge)
	hide_label.text = str(hid)
	close_enc_label.text = str(hover)
	dodge_label.text = str(dodge)
	game_over_screen.visible = true


func _on_button_pressed():
	get_tree().reload_current_scene()
