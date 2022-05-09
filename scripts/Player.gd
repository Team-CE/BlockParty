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
func move(pos: Vector2) -> void:
  $Sprite.flip_h = (pos.x < position.x)
  # If way is blocked then abort movement
  if !can_move(pos):
    state = STATE.IDLE
    return
  
  target_pos = pos
  _reached = false
  state = STATE.WALK

func can_move(pos: Vector2) -> bool:
  return !(Global.get_tile(pos) in SOLID)

func check_ground() -> void:
  var tile: int = Global.get_tile(position + Vector2.DOWN * 16)
  _on_ground = tile in SOLID or tile in LADDER or Global.get_tile(position + Vector2.UP * 16) in LADDER

func can_climb(down:bool) -> bool:
  # If tile you in is ladder and up tile is ladde or air you can move up and down the same
  var tile: int = Global.get_tile(position + Vector2.UP * 48) if !down else Global.get_tile(position + Vector2.DOWN * 16)
  return (tile in LADDER or tile == -1) and Global.get_tile(position + Vector2.UP * 16) in LADDER

func _process(_delta):
  check_ground()
  if !_reached:
    position = position.move_toward(target_pos,speed)
    # If already reached
    _reached = position == target_pos
    if _reached:
      # If input still pressed countinue playing animation
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
  var dir_y: float = Input.get_axis('m_up',  'm_down' )
  
  if dir_y != 0:
    if can_climb(dir_y < 0):
      move(position + Vector2(0,dir_y * 32))
      state = STATE.CLIMB
      return true
  if dir_x != 0:
    # Then move a player
    move(position + Vector2(dir_x * 32,0))
    return true
  return false

func animation() -> void:
  if state == STATE.IDLE and $Sprite.frame == 2:
    $Sprite.playing = false
    $Sprite.animation = 'default'
  elif state != STATE.IDLE:
    if state == STATE.FALL:
      $Sprite.animation = 'default'
      $Sprite.playing = false
      $Sprite.frame = 2
    if state == STATE.CLIMB and $Sprite.animation != 'climb':
      $Sprite.animation = 'climb'
      $Sprite.playing = !_reached
  
  
  
