extends Node3D


@onready var sphere_1 = $Sphere1
@onready var sphere_2 = $Sphere2

var spring_constant = 100.0
var gravity = 9.80
var damping_rate = 1.0
var velocity = Vector3()
var density = 1.0
	
	
class Point:
	var pos: Vector3 = Vector3()
	var force: Vector3 = Vector3()
	var velocity: Vector3 = Vector3()
	var rest_length: float = 0.0
	var mass: float = 0.0
	
	func _init(pos: Vector3):
		self.pos = pos
	
	
var points = []
var spheres = []

func _ready():
	var initial_pos = sphere_1.position
	var final_pos = sphere_2.position
	var segment_interval = 0.5
	var distance = initial_pos.distance_to(final_pos)
	var dir = initial_pos.direction_to(final_pos)
	var segment_count = ceil(distance / segment_interval)
	var corrected_interval = distance / segment_count
	var segment_mass = density * distance / segment_count
	
	for i in range(segment_count + 1):
		var pos = initial_pos + dir * (corrected_interval * i)
		var point = Point.new(pos)
		point.rest_length = corrected_interval
		point.mass = segment_mass
		points.append(point)
		
		var sphere = CSGSphere3D.new()
		add_child(sphere)
		sphere.radius = 0.05
		spheres.append(sphere)
	
	
func _physics_process(delta):
	if Input.is_action_pressed("ui_right"):
		points[0].pos.x += 5.0 * delta
	if Input.is_action_pressed("ui_left"):
		points[0].pos.x -= 5.0 * delta
	
	for i in range(1, points.size() - 1):
		var prev_point = points[i - 1]
		var point = points[i]
		var next_point = points[i + 1]

		var f_spring0 = calculate_spring_force(point, prev_point)
		var f_spring1 = calculate_spring_force(next_point, point)
		point.force = f_spring0 - f_spring1
		
		
	points[-1].force = calculate_spring_force(points[-1], points[-2])
		
	
	for i in range(1, points.size()):
		var point = points[i]
		var f_gravity = Vector3(0, -point.mass * gravity, 0)
		var f_damping = -point.velocity * damping_rate
		var acceleration = (point.force + f_gravity + f_damping) / point.mass 
		point.velocity += acceleration * delta
		point.pos += point.velocity * delta
		
	for i in range(points.size()):
		spheres[i].position = points[i].pos
		
	sphere_1.position = points[0].pos
	sphere_2.position = points[-1].pos
		

func calculate_spring_force(from: Point, to: Point):
	var displacement = from.pos - to.pos
	var x = displacement.length() - from.rest_length
	var f_spring = -spring_constant * x * displacement.normalized()

	return f_spring 
	# + f_gravity + f_damping
	#var displacement =sphere_2.position -  sphere_1.position
	#var x = displacement.length() - rest_length
	#var f_spring = -spring_constant * x * displacement.normalized()
	#var f_gravity = Vector3(0, -mass * gravity, 0)
	#var f_damping = -velocity * damping_rate
	#
	#var force = f_spring + f_gravity + f_damping
	#var acceleration = force / mass
	#velocity += acceleration * delta
	#sphere_2.position += velocity *delta
