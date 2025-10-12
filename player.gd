extends CharacterBody2D

# 角色移动速度，你可以根据需要调整这个值
@export var speed: float = 150.0
@onready var action_finder: Area2D = $ActionFinder
# 获取对 AnimatedSprite2D 节点的引用，方便后续调用
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		var actionables = action_finder.get_overlapping_areas()
		for obj in actionables:  # 遍历所有可交互对象
			var parent = obj.get_parent()
			if parent.has_method("action"):  # 检查是否有action方法
				# --- 这是唯一的修改 ---
				# 将 self (即玩家节点本身) 作为参数传递给 action 方法
				parent.action(self) 
				# --------------------
				break
				
func _physics_process(delta: float) -> void:
	if  PlayerState.is_pause:
		return
		# 1. 获取输入
		# get_vector 会自动处理 "ui_left", "ui_right", "ui_up", "ui_down" 的输入
		# 并返回一个归一化的向量 (长度为1)，确保斜向移动不会更快
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

		# 2. 设置速度
	velocity = direction * speed

		# 3. 执行移动和碰撞
		# move_and_slide 是 CharacterBody2D 的核心函数，它会移动角色并处理碰撞
	move_and_slide()

		# 4. 更新动画
	update_animation(direction)

func update_animation(direction: Vector2) -> void:
	# 如果角色在移动
	if direction != Vector2.ZERO:
		# 根据方向播放不同的行走动画
		if direction.y < 0:
			animated_sprite.play("walk_up")
		elif direction.y > 0:
			animated_sprite.play("walk_down")
		elif direction.x < 0:
			animated_sprite.play("walk_left")
		elif direction.x > 0:
			animated_sprite.play("walk_right")
	else:
		# 停止时，可以根据之前的动画名称来播放对应的站立动画
		var current_anim = animated_sprite.animation
		if current_anim == "walk_up":
			animated_sprite.play("idle_up") 
		elif current_anim == "walk_down":
			animated_sprite.play("idle_down")
		if current_anim == "walk_left":
			animated_sprite.play("idle_left") 
		elif current_anim == "walk_right":
			animated_sprite.play("idle_right")	
