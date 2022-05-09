extends KinematicBody2D

var velocity: Vector2 = Vector2.ZERO
var x_counter: float = 0
var delay: float = 0
var calculate: bool = false

var moving: bool = false

var identity: String = 'player'

var calculated_pos: Vector2 = Vector2.ZERO

func _process(delta):
  $Collision.disabled = abs(x_counter) > 0
  $BodyKeeper/Collision.disabled = abs(x_counter) == 0
  
  if !moving:
    $Icon.playing = false
    $Icon.frame = 2
  elif !$Icon.playing:
    $Icon.playing = true

  if !is_on_floor() and x_counter == 0:
    velocity.y = 150
    
  velocity = move_and_slide(velocity)
  
  if Input.is_action_pressed("ui_right") and x_counter == 0 and velocity.y == 0 and delay == 0 and !moving:
    if !len($RightDetector.get_overlapping_bodies()):
      x_counter = 32
      moving = true
    else: for body in $RightDetector.get_overlapping_bodies():
      if 'identity' in body and body.identity == 'block' and body.x_counter == 0:
        body.x_counter = 32
        delay = 16
  elif Input.is_action_pressed("ui_left") and x_counter == 0 and velocity.y == 0 and delay == 0 and !moving:
    if !len($LeftDetector.get_overlapping_bodies()):
      x_counter = -32
      moving = true
    else: for body in $LeftDetector.get_overlapping_bodies():
      if 'identity' in body and body.identity == 'block' and body.x_counter == 0:
        body.x_counter = -32
        delay = 16
    
  if (x_counter == 32 or x_counter == -32) and !calculate:
    calculate = true
    calculated_pos = position + Vector2(x_counter, 0)

  if x_counter > 0:
    x_counter -= 1.9 * Global.get_delta(delta)
    velocity.x = 120
  if x_counter < 0:
    x_counter += 1.9 * Global.get_delta(delta)
    velocity.x = -120
  if abs(x_counter) < 1 and moving:
    calculate = false
    moving = false
    position = calculated_pos
    x_counter = 0
    velocity.x = 0
  
  if x_counter < 0:
    $Icon.flip_h = true
  elif x_counter > 0:
    $Icon.flip_h = false
  
  if delay > 0:
    delay -= 1 * Global.get_delta(delta)
  elif delay < 0:
    delay = 0
