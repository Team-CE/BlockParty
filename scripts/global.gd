extends Node

static func get_delta(delta) -> float:       # Delta by 60 FPS
  return 60 / (1 / (delta if not delta == 0 else 0.0001))
