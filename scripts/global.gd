extends Node

enum SOUND_TYPE {
  YAY,
  DEATH
}

const SOUNDS_DIR = 'res://assets/sounds/'

var main_tilemap: TileMap
var sounds: Dictionary
var sound_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _init():
  sounds[SOUND_TYPE.DEATH] = [load(SOUNDS_DIR+'death1.ogg'),load(SOUNDS_DIR+'death2.ogg'),load(SOUNDS_DIR+'death3.ogg')]
  sounds[SOUND_TYPE.YAY]  = [load(SOUNDS_DIR+'yay1.ogg'),load(SOUNDS_DIR+'yay2.ogg'),load(SOUNDS_DIR+'yay3.ogg')]

func _ready():
  sound_player.owner = self
  add_child(sound_player)

static func get_delta(delta: float) -> float:       # Delta by 60 FPS
  return 60 / (1 / (delta if not delta == 0 else 0.0001))

func get_tile(position: Vector2) -> int:
  if main_tilemap != null:
    return main_tilemap.get_cell(int(position.x / 32),int((position.y - 1) / 32))
  return -2

func play_sound(sound:int) -> void:
  if sound_player.playing:
    return
  var rng = RandomNumberGenerator.new()
  rng.randomize()
  sound_player.stream = sounds[sound][rng.randi_range(0,sounds[sound].size()-1)]
  sound_player.play()
