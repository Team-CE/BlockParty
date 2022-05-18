extends Node

enum PLACEMENT{
  NONE = -1,
  BOMB,
  LADDER,
  TILE
}

var bomb_scene = preload('res://objects/bomb.tscn')

var current_selected: int = PLACEMENT.BOMB

var bombs: int   = 10
var ladders: int = 10
var tiles: int   = 10

func place(pos: Vector2) -> void:
  match current_selected:
    PLACEMENT.BOMB:
      place_bomb(pos)
    PLACEMENT.LADDER:
      place_tile(pos,1)
    PLACEMENT.TILE:
      place_tile(pos,2)

# Places bombs
func place_bomb(pos: Vector2) -> void:
  # Getting a bomb instace
  var b: Area2D = bomb_scene.instance()
  # Setting a bomb position
  b.position = pos
  # Adding a bomb to a scene
  get_tree().current_scene.add_child(b)
  b.owner = get_tree().current_scene
  # Subtract a count of bombs
  bombs = clamp(bombs - 1, 0, 99)

# Places tile
func place_tile(pos: Vector2, type:int) -> void:
  var x: int = int(pos.x / 32)
  var y: int = int(pos.y / 32) - 1
  print('position: %s %s' % [x,y])
  Global.main_tilemap.set_cell(x,y,type)
  Global.main_tilemap.update_bitmask_region(Vector2(x-1,y+1),Vector2(x+1,y-1)) # Autotile
  # Subtract a count of tiles
  tiles = clamp(tiles - 1, 0, 99)


func _process(_delta: float) -> void:
  # Temporary
  if Input.is_action_just_pressed("m_prev") or Input.is_action_just_pressed("m_next"):
    var dir: int = int(Input.get_axis('m_prev','m_next'))
    if dir != 0:
      toggle(dir)

# Toggle current selection
func toggle(amount: int) -> void:
  current_selected += amount
  if current_selected > PLACEMENT.TILE:
    current_selected = PLACEMENT.BOMB
  elif current_selected < PLACEMENT.BOMB:
    current_selected = PLACEMENT.TILE
  
  print(current_selected)
  # Handle
  if Global.player_UI == null:
    return
  # Didn't work no time for fix
  Global.player_UI.get_node('Control/Selection/Bombs').modulate = Color.white
  Global.player_UI.get_node('Control/Selection/Ladders').modulate = Color.white
  Global.player_UI.get_node('Control/Selection/Blocks').modulate = Color.white
  
  match current_selected:
    PLACEMENT.BOMB:
      Global.player_UI.get_node('Control/Selection/Bombs').modulate = Color.red
    PLACEMENT.LADDER:
      Global.player_UI.get_node('Control/Selection/Ladders').modulate = Color.red
    PLACEMENT.TILE:
      Global.player_UI.get_node('Control/Selection/Blocks').modulate = Color.red
