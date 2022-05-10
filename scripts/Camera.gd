extends Camera2D

func _process(delta):
  zoom += (Global.target_camera_zoom - zoom) * 0.2 * Global.get_delta(delta)

func _input(event):
  if event.is_action_pressed('zoom_in'):
    Global.target_camera_zoom = Vector2(max(0.5, Global.target_camera_zoom.x - 0.25), max(0.5, Global.target_camera_zoom.y - 0.25))
  if event.is_action_pressed('zoom_out'):
    Global.target_camera_zoom = Vector2(min(2, Global.target_camera_zoom.x + 0.25), min(2, Global.target_camera_zoom.y + 0.25))
