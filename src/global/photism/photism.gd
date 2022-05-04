extends Node2D

var draw_rel_pos: = Vector2(0.5, 0.5)
var lifetime: = 0.0
var curr_radius: = 0.0
# the values taken by the curve are assumed to be between 0 and 1
export(PoolVector2Array) var radius_control_points: = PoolVector2Array()
export(float, 1, 100) var scaler: = 50.0

var bezier: Bezier

var initialized: = false

func quadratic(t: float) -> float:
	# quadradic radius function
	var duration: float = 2.5  # seconds
	var max_radius: float = 25  # pixels
	
	var r = max_radius*(1 - pow(2*t/duration - 1, 2)) 
	return r

func initialize(
	draw_rel_pos: = self.draw_rel_pos,
	radius_control_points: = self.radius_control_points,
	scaler: float = self.scaler):
	
	self.draw_rel_pos = draw_rel_pos
	self.scaler = scaler
	self.bezier = Bezier.new(radius_control_points)
	initialized = true
	return self

func radius(time: float) -> float:
	return scaler*bezier.function(time)


func _ready():
	if not initialized:
		initialize()
	set_physics_process(false)
	yield(get_tree().create_timer(2.0), "timeout")
	set_physics_process(true)

func _draw():
	var abs_pos: Vector2 = System.toAbsolute(draw_rel_pos)
	draw_circle(abs_pos, curr_radius, Color.white)

func _physics_process(delta):
	lifetime += delta
	curr_radius = radius(lifetime)
	
	if curr_radius < 0:
		call_deferred("queue_free")
		set_physics_process(false)
	
	update()
