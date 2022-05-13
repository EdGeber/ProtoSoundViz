extends Node2D

export(String) var animation_folder_path: String = "res://src/animations/steps/"
export(int, 1, 500) var scale_factor: float = 50.0
export(float, -5, 5) var video_delay: float = 0
"""export(float, 0.1, 2)""" var speed: float = 1
var _pig_sound_photism

var photism_resource: = preload("res://src/global/photism/photism.tscn")
var references: Dictionary
var timbres: Dictionary

func dictToPhotism(sound_dict: Dictionary):
	var sound_name: String = sound_dict["sound"]

	var intens_points: PoolVector2Array = System.arrayToPoolVector2(
		references[sound_name]["intensity_points"])
	var pitch_points: PoolVector2Array = System.arrayToPoolVector2(
		references[sound_name]["pitch_points"])
	var timbre_name: String = references[sound_name]["timbre"]
	
	var duration: float = sound_dict["duration"]
	var strength: float = sound_dict["strength"]
	var timestamp: float = sound_dict["timestamp"]

	
	var base_color: Color = System.arrayToColor(timbres[timbre_name]["color"])
	var height: float = 1 - timbres[timbre_name]["height"]

	add_child(
		photism_resource.instance().initialize(
			intens_points,
			pitch_points,
			base_color,
			height,
			timestamp,
			scale_factor,
			duration,
			strength
		)
	)

func _ready():
	var video_resource: = load(animation_folder_path + "video.webm")
	var video_player: = get_node("VideoPlayer")
	video_player.stream = video_resource

	references = System.jsonPathToDict(animation_folder_path + "references.json")
	timbres = System.jsonPathToDict(animation_folder_path + "timbres.json")

	var sounds: Dictionary = System.jsonPathToDict(
		animation_folder_path + "sounds.json")

	if video_delay < 0:  # bring forward the video
		video_player.play()
		yield(get_tree().create_timer(-1*video_delay), "timeout")
	
	var i: int = 1
	for sound_dict in sounds["sounds"]:
		dictToPhotism(sound_dict)
		if(sound_dict["sound"] == "pig_sound_1/3"):
			self._pig_sound_photism = self.get_child(i)
			#breakpoint
		i += 1

	if video_delay > 0:  # delay the video
		yield(get_tree().create_timer(video_delay), "timeout")
		video_player.play()

	Engine.time_scale = speed
