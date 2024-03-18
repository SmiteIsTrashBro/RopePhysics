extends Node3D


@onready var ball_1 = $Sphere1
@onready var ball_2 = $Sphere2


var velocity = Vector3()
var mass = 1.0
var gravity = 9.81
var friction = 1.0
var rest_point = Vector3()
var velocity_2 = Vector3()


func _physics_process(delta):
	simulate_ball_1(delta)
	simulate_ball_2(delta)
	
	
func simulate_ball_1(delta):
	var net_force = Vector3()
	
	if Input.is_action_pressed("ui_right"):
		net_force.x += 10.0
		
	if Input.is_action_pressed("ui_left"):
		net_force.x -= 10.0
		
	var f_friction = velocity_2 * friction
	net_force -= f_friction
	
	var acceleration = net_force / mass
	velocity_2 += acceleration * delta
	ball_1.position += velocity_2 * delta
	
	rest_point = ball_1.position + Vector3(0, -1.5, 0)
	
	
func simulate_ball_2(delta):
	var net_force = Vector3()
	net_force.y -= mass * gravity
	
	var displacement = ball_2.position - rest_point
	var spring_constant = 50.0
	var f_spring = displacement.normalized() * spring_constant * displacement.length()
	net_force -= f_spring
	
	var damping_rate = 1.0
	var f_damping = velocity * damping_rate
	net_force -= f_damping
	
	var acceleration = net_force / mass
	velocity += acceleration * delta
	ball_2.position += velocity * delta
