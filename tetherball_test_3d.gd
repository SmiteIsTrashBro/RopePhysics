extends Node3D


class VerletRope:
	
	class Point:
		var locked: bool = false
		var pos: Vector3 = Vector3()
		var last_pos: Vector3 = Vector3()
		
		func _init(pos: Vector3, locked: bool = false):
			self.pos = pos
			self.last_pos = pos
			self.locked = locked
		
	class Stick:
		var point_a: Point
		var point_b: Point
		var length: float
		
		func _init(point_a: Point, point_b: Point, length: float):
			self.point_a = point_a
			self.point_b = point_b
			self.length = length
		
		
	var points: Array[Point] = []
	var sticks: Array[Stick] = []
	var gravity = 100.0
	var num_iterations = 30
	
	func _init(from: Vector3, to: Vector3, segment_distance: float, num_iterations: int = 30, gravity: float = 100.0) -> void:
		self.gravity = gravity
		self.num_iterations = num_iterations
		
		var rope_length = from.distance_to(to)
		var dir = from.direction_to(to)
		var segment_count = int(rope_length / segment_distance)
		var last_point = null
		
		for i in range(segment_count + 1):
			var pos = from + dir * (i * segment_distance)
			var point = Point.new(pos)
			self.points.append(point)
			
			if last_point:
				var length = last_point.pos.distance_to(point.pos)
				var stick = Stick.new(last_point, point, length)
				self.sticks.append(stick)
				
			last_point = point
		
	
	func simulate(delta: float) -> void:
		for point in points:
			if not point.locked:
				var last_pos = point.pos
				point.pos += point.pos - point.last_pos
				point.pos += Vector3.DOWN * gravity * delta * delta
				point.last_pos = point.pos
				
		for i in range(num_iterations):
			for stick in sticks:
				var center = (stick.point_a.pos + stick.point_b.pos) / 2.0
				var dir = (stick.point_a.pos - stick.point_b.pos).normalized()
				
				if not stick.point_a.locked:
					stick.point_a.pos = center + dir * stick.length / 2.0
					
				if not stick.point_b.locked:
					stick.point_b.pos = center - dir * stick.length / 2.0
					

@onready var ball = get_node("Ball")
@onready var verlet = VerletRope.new($Pole.position + Vector3(0, 2.0, 0), ball.position, 0.5)

var gravity = 9.81
var mass = 1.0
var velocity = Vector3()

var spheres = []

func _ready():
	verlet.points[0].locked = true
	verlet.points[-1].locked = true
	
	for point in verlet.points:
		var sphere = CSGSphere3D.new()
		sphere.radius = 0.1
		add_child(sphere)
		sphere.position = point.pos
		spheres.append(sphere)
			
		
func _physics_process(delta):
	verlet.points[-1].pos = ball.position
	verlet.simulate(delta)
	
	for i in range(verlet.points.size()):
		spheres[i].position = verlet.points[i].pos
	
	var net_force = Vector3()
	net_force.y -= mass * gravity
	
	var tension = calculate_tension(ball.position, verlet.points[-2].pos)
	net_force += tension
	
	var acceleration = net_force/ mass
	velocity += acceleration * delta
	ball.position += velocity * delta
	
	
func calculate_tension(start: Vector3, end: Vector3):
	var displacement = end - start
	
	var spring_constant = 100.0
	var force = displacement * spring_constant
	
	return force
