# window_red.gd
extends StaticBody2D

# --- 导出变量 (请在 Godot 编辑器中设置这些值) ---
@export var dialogue_resource: Resource 
@export var dialogue_title: String = "start"

# --- 预加载资源 ---
# 请确保这个路径指向您项目中实际的对话气泡场景
const BALLON = preload("res://dialogue/example_balloon/dialoguebox.tscn") 

# --- 节点引用 ---
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var sprite_2d_2: Sprite2D = $Sprite2D2

func _process(delta: float) -> void:
	_open_curtain()

# 这是新的互动函数，由 player.gd 调用
func action(player: CharacterBody2D) -> void:
	# 实例化并启动对话
	var ballon: Node = BALLON.instantiate()
	get_tree().get_root().add_child(ballon)
	ballon.start(dialogue_resource, dialogue_title)

func _open_curtain():
	if PlayerState.open_curtain:
		sprite_2d_2.hide()
		sprite_2d.show()
