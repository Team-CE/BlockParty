extends Node

enum SOUND_TYPE {
  YAY,
  DEATH
}

const SOUNDS_DIR = 'res://assets/sounds/'

var sounds: Dictionary

func _init() -> void:
  sounds[SOUND_TYPE.DEATH] = [load(SOUNDS_DIR+'death1.ogg'),load(SOUNDS_DIR+'death2.ogg'),load(SOUNDS_DIR+'death3.ogg')]
  sounds[SOUND_TYPE.YAY]  = [load(SOUNDS_DIR+'yay1.ogg'),load(SOUNDS_DIR+'yay2.ogg'),load(SOUNDS_DIR+'yay3.ogg')]

func get_random_sound(sound:int) -> AudioStreamOGGVorbis:
  var rng = RandomNumberGenerator.new()
  rng.randomize()
  return sounds[sound][rng.randi_range(0,sounds[sound].size()-1)]
