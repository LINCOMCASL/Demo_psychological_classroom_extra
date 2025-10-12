extends StaticBody2D

# 使用 @onready 提前获取节点引用，更安全高效
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_closed: CollisionShape2D = $Collision_Closed
@onready var collision_open: CollisionShape2D = $Collision_Open
@onready var interaction_area: Area2D = $InteractionArea

# 状态变量，用于跟踪门的状态和玩家位置
var is_open: bool = false
var player_is_near: bool = false
# 新增：判断门是否正在运动中（开门或关门）
var is_animating: bool = false 

func _ready() -> void:
	# 在游戏开始时连接信号，这是最佳实践
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	# 当动画播放完成时，会调用对应的函数
	animated_sprite.animation_finished.connect(_on_animation_finished)

# 这个函数处理玩家输入
func _unhandled_input(event: InputEvent) -> void:
	# 确保门不在动画播放中，防止玩家重复输入
	if is_animating:
		return

	# **开门逻辑**
	# 检查：玩家是否在附近？门是否还关着？是否按下了“interact”键？
	if player_is_near and not is_open and event.is_action_pressed("interact"):
		open_door()

	# **手动关门逻辑 (可选)**
	# 如果门是开着的，玩家在附近，并且按下了“interact”键，则关门
	elif player_is_near and is_open and event.is_action_pressed("interact"):
		close_door()


func open_door() -> void:
	# 将门的状态更新为“正在播放动画”
	is_animating = true
	# 将门的状态更新为“已打开”
	is_open = true
	# 播放开门动画
	animated_sprite.play("opening")
	# 立刻禁用“关闭”时的碰撞体，防止动画播放时还挡着玩家
	collision_closed.disabled = true
	# 禁用“打开”时的碰撞体，因为动画播放中还不是完全打开的状态
	collision_open.disabled = true 

# --- 新增的关门函数 ---
func close_door() -> void:
	# 将门的状态更新为“正在播放动画”
	is_animating = true
	# 将门的状态更新为“未打开”
	is_open = false
	# 播放关门动画
	animated_sprite.play("closing")
	# 立刻禁用“打开”时的碰撞体
	collision_open.disabled = true
	# 禁用“关闭”时的碰撞体，防止动画播放时门还没完全关上就挡路
	collision_closed.disabled = true

# --- 信号回调函数 ---

func _on_body_entered(body: Node2D) -> void:
	# 检查进入区域的是否是玩家
	if body.is_in_group("player"):
		player_is_near = true

func _on_body_exited(body: Node2D) -> void:
	# 检查离开区域的是否是玩家
	if body.is_in_group("player"):
		player_is_near = false

func _on_animation_finished() -> void:
	# 动画播放完成，更新状态
	is_animating = false 

	# 检查是否是“opening”动画播放完毕
	if animated_sprite.animation == "opening":
		# 动画放完了，现在启用“打开”时的碰撞体（门框）
		collision_open.disabled = false
		
	# **新增：处理“closing”关门动画播放完毕**
	elif animated_sprite.animation == "closing":
		# 关门动画放完了，现在启用“关闭”时的碰撞体（把门重新变成障碍物）
		collision_closed.disabled = false
