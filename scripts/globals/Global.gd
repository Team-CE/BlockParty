extends Node

const SOLID  = [0, 2]
const LADDER = [1]


var main_tilemap: TileMap
var mario_dead: bool
var target_camera_zoom = Vector2(1, 1)

var player: Node2D
var player_UI: CanvasItem
var camera: Camera2D


var _dead_counter: float

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
  player = get_tree().current_scene.get_node('Player')

static func get_delta(delta: float) -> float:       # Delta by 60 FPS
  return 60 / (1 / (delta if not delta == 0 else 0.0001))
  
static func get_delta_vector(delta: float) -> Vector2:
  var calc_delta = get_delta(delta)
  return Vector2(calc_delta, calc_delta)

func get_tile(position: Vector2) -> int:
  if main_tilemap != null:
    return main_tilemap.get_cell(int(position.x / 32),int((position.y - 1) / 32))
  return -2

func kill_mario() -> void:
  if mario_dead: return

  SoundPlayer.play_sound(SoundPlayer.SOUND_TYPE.DEATH)
  mario_dead = true

func _process(delta: float) -> void:
  if mario_dead:
    _dead_counter += 1
    
    if _dead_counter > 400:
      get_tree().reload_current_scene()
