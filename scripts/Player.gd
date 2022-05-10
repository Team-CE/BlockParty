extends Node2D

enum STATE {
  IDLE,
  WALK,
  FALL,
  DEAD,
  CLIMB
}

var target_pos: Vector2
var speed: float = 2
var state: int = STATE.IDLE

var _reached: bool = true
var _on_ground: bool
var _block_time: float
var _fall_counter: int

var fly_velocity: Vector2

func _ready():
  Global.mario_dead = false
  Global._dead_counter = 0
  fly_velocity = Vector2(Global.rng.randf_range(-3, 3), Global.rng.randf_range(-5, -4))

# Just setter for target_pos
func move(pos: Vector2, set_state = STATE.WALK) -> void:
  if pos.x != position.x:
    $Sprite.flip_h = (pos.x < position.x)
  # If way is blocked then abort movement
  if !can_move(pos):
    if state != STATE.CLIMB:
      state = STATE.IDLE
    return
  
  for i in $Right_side.get_overlapping_areas():
    if i is Interactive:
      if pos.x > position.x:
        if '_on_ground' in i and !i._on_ground:
          continue
        i.activate(Vector2.RIGHT)
        state = STATE.IDLE
        _block_time = 10
  for i in $Left_side.get_overlapping_areas():
    if i is Interactive:
      if pos.x < position.x:
        if '_on_ground' in i and !i._on_ground:
          continue
        i.activate(Vector2.LEFT)
        state = STATE.IDLE
        _block_time = 10
      
  if _block_time > 0:
    return
  
  target_pos = pos
  _reached = false
  state = set_state

# MOVE SYSTEM AND PULL SYSTEM HERE
func can_move(pos: Vector2) -> bool:
  var result: bool
  if pos.x > position.x:
    result = $Right_side.get_overlapping_areas().size() <= 0
  elif pos.x < position.x:
    result = $Left_side.get_overlapping_areas().size() <= 0
  
  return !(Global.get_tile(pos) in Global.SOLID) or result

func check_ground() -> void:
  var tile: int = Global.get_tile(position + Vector2.DOWN * 16)
  _on_ground = (
    tile in Global.SOLID or
    tile in Global.LADDER or
    Global.get_tile(position + Vector2.UP * 16) in Global.LADDER or
    $Bottom_side.get_overlapping_areas().size() > 0
  )

func can_climb(down: bool) -> bool:
  # If tile you're in and the upper tile is a Global.LADDER or air you can move
  var tile: int = Global.get_tile(position + Vector2.UP * 16) if !down else Global.get_tile(position + Vector2.DOWN * 16)
  return (
    (tile in Global.LADDER or tile == -1) and
    (
      (
        !down and
        !(Global.get_tile(position + Vector2.UP * 48) in Global.SOLID) and
        Global.get_tile(position + Vector2.UP * 16) in Global.LADDER
      ) or
      (
        down and
        (
          (Global.get_tile(position + Vector2.DOWN * 16) in Global.LADDER) or
          (Global.get_tile(position + Vector2.UP * 16) in Global.LADDER)
        )
      )
    )
  )

func _process(delta):
  if Global.mario_dead:
    _process_dead(delta)
    return
    
  check_ground()
  
  if position.y > $Camera2D.limit_bottom + 16:
    Global.kill_mario()
  
  if _block_time > 0:
    _block_time -= Global.get_delta(delta)
  
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
        _fall_counter += 1
        state = STATE.FALL
      elif !check_inputs():
        _fall_counter = 0
        state = STATE.IDLE
  else:
    if !_on_ground:
      move(position + Vector2.DOWN * 32)
      _fall_counter += 1
      state = STATE.IDLE
    else:
      _fall_counter = 0
      # warning-ignore:return_value_discarded
      check_inputs()
  
  if _fall_counter == 4:
    Global.play_sound(Global.SOUND_TYPE.YAY)
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
    
  if !(Global.get_tile(position + Vector2.UP * 2) in Global.LADDER) and $Sprite.animation == 'climb':
    $Sprite.animation = 'default'
  
  $Sprite.offset.y = 0 - $Sprite.frames.get_frame($Sprite.animation, $Sprite.frame).get_size().y

func _process_dead(delta):
  $Sprite.offset.y = 0
  $Sprite.position += fly_velocity * Global.get_delta_vector(delta)
  fly_velocity.y += 0.05 * Global.get_delta(delta)
  $Sprite.rotation_degrees += fly_velocity.x * 3 * Global.get_delta(delta)

