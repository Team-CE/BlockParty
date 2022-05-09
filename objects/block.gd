extends KinematicBody2D

var velocity: Vector2 = Vector2.ZERO
var x_counter: float = 0
var calculate: bool = false

var calculated_pos: Vector2 = Vector2.ZERO

var identity: String = 'block'

func _ready():
  calculated_pos = position

func _process(delta):
  if !is_on_floor() and x_counter == 0:
    velocity.y = 150
  else:
    velocity.y = 0
  
  $CollisionShape2D.disabled = abs(x_counter) > 0
  $BodyKeeper/Collision.disabled = abs(x_counter) == 0
    
  velocity = move_and_slide(velocity, Vector2.UP)
    
  if (x_counter == 32 or x_counter == -32) and !calculate:
    for body in $Detector.get_overlapping_bodies():
      if 'identity' in body and body.identity == 'block' and body != self:
        x_counter = 0
        return

    calculate = true
    calculated_pos = position + Vector2(x_counter, 0)

  if x_counter > 0:
    x_counter -= 1.4 * Global.get_delta(delta)
    velocity.x = 90
  if x_counter < 0:
    x_counter += 1.4 * Global.get_delta(delta)
    velocity.x = -90
  if abs(x_counter) < 1 and x_counter != 0:
    calculate = false
    position = calculated_pos
    x_counter = 0
    velocity.x = 0
  if x_counter == 0:
    position.x = calculated_pos.x
  
  
