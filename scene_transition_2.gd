extends Area2D

## 导出一个变量，让我们可以在编辑器中设置要跳转到哪个场景
## (String, FILE) 会在检查器中显示一个文件选择框，非常方便
@export_file("*.tscn") var next_scene_path: String = ""

# 跟踪玩家是否在区域内
var player_is_near: bool = false

func _ready() -> void:
	# 连接信号
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	# 检查：玩家是否在附近？是否按下了“interact”键？
	if player_is_near and event.is_action_pressed("interact"):
		# 示例：在你的 SceneTransition 脚本中
		# 在切换场景前，先命令 MusicPlayer 切换音乐
		# 1. 加载你想要的音乐资源
		var hallway_music = load("res://assets/bgm/樋口秀樹 - 学び舎で交わす挨拶.mp3")
		# 2. 调用全局单例
		MusicPlayer.change_music(hallway_music)
		# 然后执行场景切换
		# 检查我们是否真的设置了下一个场景的路径
		if not next_scene_path.is_empty():
			# 这就是切换场景的核心命令！
			get_tree().change_scene_to_file(next_scene_path)
		else:
			print("错误：未在 SceneTransition 节点上设置 next_scene_path！")

# --- 信号回调函数 ---

func _on_body_entered(body: Node2D) -> void:
	# 检查进入的是否是玩家（使用我们之前设置的 "player" 编组）
	if body.is_in_group("player"):
		player_is_near = true
		# 提示：你可以在这里添加一个视觉提示，比如显示一个"按E"的图标

func _on_body_exited(body: Node2D) -> void:
	# 检查离开的是否是玩家
	if body.is_in_group("player"):
		player_is_near = false
		# 提示：如果显示了提示图标，在这里将其隐藏
