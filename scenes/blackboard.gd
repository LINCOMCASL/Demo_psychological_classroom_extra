# blackboard.gd
extends StaticBody2D

signal blackboard_state_changed(texture: Texture2D)

# --- 导出变量 (请在 Godot 编辑器中设置这些值) ---
# 你的对话资源文件 (.tres)
@export var dialogue_resource: Resource 
# 对话的起始标题 (例如 "start" 或 "blackboard_talk")
@export var dialogue_title: String = "start"

# --- 预加载资源 ---
const BlackboardPopupScene = preload("res://blackboard_popup.tscn") # <-- 确认路径正确!
const BALLON = preload("res://dialogue/example_balloon/dialoguebox.tscn") # <-- 替换为你的对话气泡场景的正确路径!

# 预加载纹理
const TEXTURE_DEFAULT = preload("res://assets/objects/blackboard_0.png")
const TEXTURE_BAD = preload("res://assets/objects/blackboard_1.png")
const TEXTURE_GOOD = preload("res://assets/objects/blackboard_2.png")

# --- 节点与单例引用 ---
@onready var sprite: Sprite2D = $Sprite2D
@onready var actionable: Area2D = $Actionable
# 获取对 DialogueManager 单例的引用，以便连接其信号
@onready var DialogueManager = get_node("/root/DialogueManager") # 假设它是一个自动加载的单例

# --- 变量 ---
var popup_instance = null

func _ready() -> void:
	update_blackboard_visuals()

func _process(delta: float) -> void:
	var target_texture = get_target_texture()
	if sprite.texture != target_texture:
		update_blackboard_visuals()

# 交互的统一入口点，由 player.gd 调用
func action(player: CharacterBody2D) -> void:
	# --- 步骤 1: 创建并显示黑板放大窗口 (如果尚未显示) ---
	if not is_instance_valid(popup_instance):
		popup_instance = BlackboardPopupScene.instantiate()
		get_tree().get_root().add_child(popup_instance)
		
		# 计算并设置窗口在玩家上方的位置
		var player_screen_position = get_viewport().get_visible_rect().size / 2.0
		var popup_size = popup_instance.size
		var offset_above_player = Vector2(0, -200)
		var target_position = player_screen_position - Vector2(popup_size.x / 2.0, popup_size.y) - offset_above_player
		popup_instance.global_position = target_position
		
		self.blackboard_state_changed.connect(popup_instance.update_blackboard_image)
		update_blackboard_visuals()

	# --- 步骤 2: 触发对话系统 ---
	# 实例化你的对话气泡
	var ballon: Node = BALLON.instantiate()
	get_tree().get_root().add_child(ballon) # 添加到场景顶层
	
	# !!! 关键步骤: 连接 DialogueManager 的对话结束信号 !!!
	# 我们将 _on_dialogue_finished 函数连接到全局 DialogueManager 的 dialogue_ended 信号。
	# 使用 CONNECT_ONE_SHOT 标志确保这个连接在触发一次后自动断开，避免多次交互产生问题。
	DialogueManager.dialogue_ended.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)
	
	# 启动对话
	ballon.start(dialogue_resource, dialogue_title)


# 当 DialogueManager 发出 dialogue_ended 信号时，此函数会被调用
func _on_dialogue_finished(resource: Resource) -> void:
	# 为了避免其他对话结束时也关闭这个窗口，可以加一个判断
	if resource != dialogue_resource:
		return

	# 检查弹出窗口实例是否仍然有效
	if is_instance_valid(popup_instance):
		# 安全地关闭并释放弹出窗口
		popup_instance.close_popup()
		# 清理引用
		popup_instance = null

# (以下函数保持不变)
func get_target_texture() -> Texture2D:
	if not PlayerState.bad_blackboard:
		if PlayerState.good_blackboard:
			return TEXTURE_GOOD
		else:
			return TEXTURE_DEFAULT
	else:
		return TEXTURE_BAD

func update_blackboard_visuals() -> void:
	var new_texture = get_target_texture()
	sprite.texture = new_texture
	emit_signal("blackboard_state_changed", new_texture)
