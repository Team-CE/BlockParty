class_name Interactive extends Area2D

export var can_move: bool
export var can_explode: bool
export var activation: Script

var speed: float = 2
var target_pos: Vector2
var _reached: bool = true
var _on_ground: bool

func check_ground() -> void:
  _on_ground = Global.get_tile(position + Vector2.DOWN * 16) != -1

func _process(delta):
  check_ground()
  if !_reached:
    position = position.move_toward(target_pos, speed * Global.get_delta(delta))
    if position == target_pos:
      _reached = true
  elif !_on_ground:
    move(Vector2.DOWN)

func move(dir:Vector2) -> void:
  if !_reached:
    return
  target_pos = position + dir * 32
  _reached = false

func on_use() -> void:
  activation.activate()
