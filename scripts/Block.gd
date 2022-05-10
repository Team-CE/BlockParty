class_name Interactive extends Area2D

export var can_move: bool
export var can_explode: bool
export var activation: Script

var speed: float = 1.5
var speed_fast: float = 2
var target_pos: Vector2
var _reached: bool = true
var _on_ground: bool = true

func check_ground() -> bool:
  _on_ground = Global.get_tile(position + Vector2.DOWN * 16) in Global.SOLID or $Bottom_side.get_overlapping_areas().size() > 0
  return _on_ground

func _process(delta):
  var _was_on_ground = _on_ground
  if check_ground() and !_was_on_ground:
    Global.play_sound_at(Global.SOUND_TYPE.BLOCK_FALL, $Move)
  if !_reached:
    if target_pos.y == position.y:
      position = position.move_toward(target_pos, speed * Global.get_delta(delta))
    else:
      position = position.move_toward(target_pos, speed_fast * Global.get_delta(delta))
    if position == target_pos:
      _reached = true
  elif !_on_ground:
    move(Vector2.DOWN)
  
  if is_instance_valid(Global.camera) and position.y > Global.camera.limit_bottom + 32:
    queue_free()

func move(dir: Vector2) -> void:
  if !_reached:
    return
  if dir.x > 0 and $Right_side.get_overlapping_areas().size() > 1:
    return
  if dir.x < 0 and $Left_side.get_overlapping_areas().size() > 1:
    return
  target_pos = position + dir * 32
  _reached = false

func activate(dir: Vector2) -> void:
  if !_on_ground:
    return
  Global.play_sound_at(Global.SOUND_TYPE.BLOCK_MOVE, $Move)
  move(dir)

func on_use() -> void:
  activation.activate()
