extends Node

# Tracks player alignment + bond and exposes helpers for mutations/endings.

signal stats_changed

var morality:int = 0   # negative = evil, positive = good
var bond:int = 0       # negative = resisting, positive = merging
var flags := {}        # arbitrary booleans/values (e.g., {"helped_scavenger": true})

func _ready():
	# Optional: preload or reset
	pass

func add_morality(delta:int):
	morality += delta
	emit_signal("stats_changed")

func add_bond(delta:int):
	bond += delta
	emit_signal("stats_changed")

func set_flag(key:String, value):
	flags[key] = value
	emit_signal("stats_changed")

func get_flag(key:String, default_value=null):
	return flags.get(key, default_value)

func reset_all():
	morality = 0
	bond = 0
	flags.clear()
	emit_signal("stats_changed")
