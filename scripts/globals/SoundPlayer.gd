extends Node

enum SOUND_TYPE {
  YAY,
  DEATH,
  BLOCK_MOVE,
  BLOCK_FALL
}

const SOUNDS_DIR = 'res://assets/sounds/'

var sounds: Dictionary
var sound_player: AudioStreamPlayer = AudioStreamPlayer.new()
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _init() -> void:
  rng.randomize()
  sounds[SOUND_TYPE.DEATH] = [load(SOUNDS_DIR+'death1.ogg'),load(SOUNDS_DIR+'death2.ogg'),load(SOUNDS_DIR+'death3.ogg')]
  sounds[SOUND_TYPE.YAY]  = [load(SOUNDS_DIR+'yay1.ogg'),load(SOUNDS_DIR+'yay2.ogg'),load(SOUNDS_DIR+'yay3.ogg')]
  sounds[SOUND_TYPE.BLOCK_MOVE]  = [load(SOUNDS_DIR+'move1.ogg'),load(SOUNDS_DIR+'move2.ogg'),load(SOUNDS_DIR+'move3.ogg')]
  sounds[SOUND_TYPE.BLOCK_FALL]  = [load(SOUNDS_DIR+'block_fall1.ogg'),load(SOUNDS_DIR+'block_fall2.ogg')]

func _ready():
  sound_player.owner = self
  add_child(sound_player)

func play_sound(sound: int) -> void:
  if sound_player.playing:
    return
  sound_player.stream = sounds[sound][rng.randi_range(0,sounds[sound].size()-1)]
  sound_player.stream.loop = false
  sound_player.play()

func play_sound_at(sound: int, player: AudioStreamPlayer2D) -> void:
  player.stream = sounds[sound][rng.randi_range(0,sounds[sound].size()-1)]
  player.stream.loop = false
  player.play()

func get_random_sound(sound:int) -> AudioStreamOGGVorbis:
  var rng = RandomNumberGenerator.new()
  rng.randomize()
  return sounds[sound][rng.randi_range(0,sounds[sound].size()-1)]
