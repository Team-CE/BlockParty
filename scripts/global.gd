extends Node

const SOLID  = [0, 2]
const LADDER = [1]

enum SOUND_TYPE {
  YAY,
  DEATH
}

const SOUNDS_DIR = 'res://assets/sounds/'

var main_tilemap: TileMap
var sounds: Dictionary
var sound_player: AudioStreamPlayer = AudioStreamPlayer.new()
var mario_dead: bool
var target_camera_zoom = Vector2(1, 1)

var _dead_counter: float

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _init():
  rng.randomize()
  sounds[SOUND_TYPE.DEATH] = [load(SOUNDS_DIR+'death1.ogg'),load(SOUNDS_DIR+'death2.ogg'),load(SOUNDS_DIR+'death3.ogg')]
  sounds[SOUND_TYPE.YAY]  = [load(SOUNDS_DIR+'yay1.ogg'),load(SOUNDS_DIR+'yay2.ogg'),load(SOUNDS_DIR+'yay3.ogg')]

func _ready():
  sound_player.owner = self
  add_child(sound_player)

static func get_delta(delta: float) -> float:       # Delta by 60 FPS
  return 60 / (1 / (delta if not delta == 0 else 0.0001))
  
static func get_delta_vector(delta: float) -> Vector2:
  var calc_delta = get_delta(delta)
  return Vector2(calc_delta, calc_delta)

func get_tile(position: Vector2) -> int:
  if main_tilemap != null:
    return main_tilemap.get_cell(int(position.x / 32),int((position.y - 1) / 32))
  return -2

func play_sound(sound: int) -> void:
  if sound_player.playing:
    return
  sound_player.stream = sounds[sound][rng.randi_range(0,sounds[sound].size()-1)]
  sound_player.stream.loop = false
  sound_player.play()

func kill_mario() -> void:
  if mario_dead: return

  play_sound(SOUND_TYPE.DEATH)
  mario_dead = true

func _process(delta: float) -> void:
  if mario_dead:
    _dead_counter += 1
    
    if _dead_counter > 400:
      get_tree().reload_current_scene()
  
