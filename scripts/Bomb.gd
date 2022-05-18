extends Area2D

export var explosion_time: float = 2.0

func _enter_tree() -> void:
  yield(get_tree().create_timer(explosion_time), "timeout")
  explode()

func explode() -> void:
  $Collision.disabled = false
  $Collision2.disabled = false
  $Explosion.play()
  $Explode.show()
  yield(get_tree().create_timer(1), "timeout")
  queue_free()


func _on_Bomb_area_entered(area: Area2D):
  if area is Interactive:
    area.broke()
  if !area.is_in_group('ignore') and area.get_parent().is_in_group('player'):
    Global.kill_mario()
