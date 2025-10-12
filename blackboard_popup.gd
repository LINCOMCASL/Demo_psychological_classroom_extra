# BlackboardPopup.gd
extends Control

# 引用场景中的 TextureRect 节点
@onready var enlarged_blackboard: TextureRect = $EnlargedBlackboard

# 这个公共函数将由 blackboard.gd 通过信号调用，用于更新显示的图片。
# 接收一个 Texture2D 资源作为参数。
func update_blackboard_image(texture: Texture2D) -> void:
	enlarged_blackboard.texture = texture

# 这个公共函数可以被外部（例如你的对话系统）调用，以关闭窗口。
func close_popup() -> void:
	queue_free()

# 为了方便测试，你也可以在这里添加一个简单的输入来关闭窗口，
# 但最终建议由你的对话或互动系统来调用 close_popup()。
func _input(event: InputEvent) -> void:
	# 当对话结束，玩家按下确认键或取消键时，关闭窗口
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		# 这是一个示例，最好的方式是让你的对话系统在结束后调用 close_popup()
		close_popup()
