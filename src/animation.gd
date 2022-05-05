extends Node2D

export(String) var animation_folder_path: String = "res://src/animations/test/"
export(int, 1, 100) var scale_factor: float = 50.0

var photism_resource: = preload("res://src/global/photism/photism.tscn")

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

func dictToPhotism(sound_dict):
	var intens_points: PoolVector2Array = arrayToPoolVector2(sound_dict["intensity_points"])
	var pitch_points: PoolVector2Array = arrayToPoolVector2(sound_dict["pitch_points"])
	var timestamp: int = sound_dict["timestamp"]
	var timbre: String = sound_dict["timbre"]

	var timbre_dict: = jsonPathToDict(animation_folder_path + "timbres.json")
	var base_color: Color = arrayToColor(timbre_dict[timbre]["color"])
	var height: float = 1 - timbre_dict[timbre]["height"]

	add_child(
		photism_resource.instance().initialize(
			intens_points,
			pitch_points,
			base_color,
			height,
			timestamp,
			scale_factor
		)
	)

func _ready():
	var allAni = jsonPathToDict(animation_folder_path + "sounds.json")
	for x in allAni["sounds"]:
		dictToPhotism(x)
	
