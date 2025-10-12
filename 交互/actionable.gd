extends Area2D
const BALLON = preload("res://dialogue/example_balloon/dialoguebox.tscn")
@export var dialogue_resource:DialogueResource
@export var dialogue_title: String = "start"

#func action()-> void:
	#var ballon: Node = BALLON.instantiate()
	#get_tree().current_scene.add_child(ballon)
	#ballon.start(dialogue_resource, dialogue_title)
