extends Node2D

enum STATE {
  IDLE,
  WALK,
  FALL,
  DEAD,
  CLIMB
}

const SOLID  = [0]
const LADDER = [1]

var target_pos: Vector2
var speed: float = 2
var state: int = STATE.IDLE
var _reached: bool = true
var _on_ground: bool

# Just setter for target_pos
func move(pos: Vector2, set_state = STATE.WALK) -> void:
  if pos.x != position.x:
    $Sprite.flip_h = (pos.x < position.x)
  # If way is blocked then abort movement
  if !can_move(pos):
    if state != STATE.CLIMB:
      state = STATE.IDLE
    return
  
  target_pos = pos
  _reached = false
  state = set_state

func can_move(pos: Vector2) -> bool:
  return !(Global.get_tile(pos) in SOLID)

func check_ground() -> void:
  var tile: int = Global.get_tile(position + Vector2.DOWN * 16)
  _on_ground = tile in SOLID or tile in LADDER or Global.get_tile(position + Vector2.UP * 16) in LADDER

func can_climb(down: bool) -> bool:
  # If tile you're in and the upper tile is a ladder or air you can move
  var tile: int = Global.get_tile(position + Vector2.UP * 16) if !down else Global.get_tile(position + Vector2.DOWN * 16)
  return (
    (tile in LADDER or tile == -1) and
    (
      (
        !down and
        !(Global.get_tile(position + Vector2.UP * 48) in SOLID) and
        Global.get_tile(position + Vector2.UP * 16) in LADDER
      ) or
      (
        down and
        (
          (Global.get_tile(position + Vector2.DOWN * 16) in LADDER) or
          (Global.get_tile(position + Vector2.UP * 16) in LADDER)
        )
      )
    )
  )

func _process(delta):
  check_ground()
  if !_reached:
    position = position.move_toward(target_pos, speed * Global.get_delta(delta))
    # If already reached
    _reached = position == target_pos
    if _reached:
      # Make sure that all animations update properly
      animation()
      # If input is still pressed countinue playing current animation
      if !_on_ground:
        move(position + Vector2.DOWN * 32)
        state = STATE.FALL
      elif !check_inputs():
        state = STATE.IDLE
  else:
    if !_on_ground:
      move(position + Vector2.DOWN * 32)
      state = STATE.IDLE
    else:
      # warning-ignore:return_value_discarded
      check_inputs()
  # Animations of player
  animation()

func check_inputs() -> bool:
  # Getting a movement direction
  var dir_x: float = Input.get_axis('m_left','m_right')
  var dir_y: float = Input.get_axis('m_up', 'm_down')
  
  if dir_y != 0:
    if can_climb(dir_y > 0):
      move(position + Vector2(0, dir_y * 32), STATE.CLIMB)
      return true
  if dir_x != 0:
    # Then move a player
    move(position + Vector2(dir_x * 32, 0))
    return true
  return false

func animation() -> void:
  if state == STATE.IDLE:
    if $Sprite.frame != 2 and !$Sprite.playing:
      $Sprite.frame = 2
    if $Sprite.frame == 2 and $Sprite.playing:
      $Sprite.playing = false
      $Sprite.animation = 'default'
  elif state != STATE.IDLE:
    if state == STATE.FALL:
      $Sprite.animation = 'default'
      $Sprite.playing = false
      $Sprite.frame = 2
    elif state == STATE.CLIMB:
      $Sprite.animation = 'climb'
      $Sprite.playing = !_reached
    else:
      $Sprite.playing = true
    
  if !(Global.get_tile(position + Vector2.UP * 2) in LADDER) and $Sprite.animation == 'climb':
    $Sprite.animation = 'default'
  
  
  
