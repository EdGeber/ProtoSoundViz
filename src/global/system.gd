extends Node

const SCREEN_WIDTH = 1024
const SCREEN_HEIGHT = 600
const SCREEN_SIZE = Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)


func toAbsoluteWidth(x: float) -> int:
	return int(x*SCREEN_WIDTH)

func toAbsoluteHeight(y: float) -> int:
	return int(y*SCREEN_HEIGHT)

func toAbsolute(v: Vector2) -> Vector2:
	return Vector2(toAbsoluteWidth(v.x), toAbsoluteHeight(v.y))

func arrayToVector2(a: Array) -> Vector2:
	return Vector2(a[0], a[1])

func arrayToPoolVector2(a: Array) -> PoolVector2Array:
	var p: = PoolVector2Array()
	for arr in a:
		p.append(arrayToVector2(arr))
	return p

func arrayToColor(a: Array) -> Color:
	return Color(a[0], a[1], a[2])

func jsonPathToDict(path) -> Dictionary:
	# https://godotengine.org/qa/117888/how-do-i-read-a-json-file
	var file: = File.new()
	file.open(path, File.READ)
	var json_text: = file.get_as_text()
	var dict: Dictionary = parse_json(json_text) 
	file.close()
	return dict
