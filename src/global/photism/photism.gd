extends Node2D

const epsilon: float = 1e-4

var draw_rel_pos: Vector2 = Vector2(0.5, 0.5)
var lifetime: float = 0.0
var curr_radius: float = 0.0

var initialized: bool = false


func equalsZero(x: float) -> bool:
	return -epsilon < x or x < epsilon

func initialize(
	pos: Vector2 = self.draw_rel_pos):
	
	self.draw_rel_pos = pos
	initialized = true
	return self

func radius(t: float) -> float:
	# quadradic radius function
	var duration: float = 2.5  # seconds
	var max_radius: float = 25  # pixels
	
	var r = max_radius*(1 - pow(2*t/duration - 1, 2)) 
	# if equalsZero(r): r = 0.0
	return r


func _enter_tree():
	if not initialized:
		initialize()

func _draw():
	var abs_pos = System.toAbsolute(draw_rel_pos)
	draw_circle(abs_pos, curr_radius, Color.white)

func _physics_process(delta):
	
	lifetime += delta
	curr_radius = radius(lifetime)
	
	if curr_radius < 0:
		call_deferred("queue_free")
		set_physics_process(false)
	
	update()
