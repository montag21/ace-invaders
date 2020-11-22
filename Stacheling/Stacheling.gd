extends KinematicBody2D

var speed = 75
var gravity = 800
const JUMP_FORCE = 300
var velocity = Vector2()
var sprite_size = Vector2(64, 64)

onready var castle_node = get_parent().get_parent().get_node("World/Background/Castle")
onready var counter_node = get_parent().get_node("Fun/StacheGuyCounter")
onready var destination = castle_node.position.x

func _ready():
	var sprite = get_node("Sprite")
	var variation = [0, 64, 128, 192, 256]
	var pick = rand_range(0, 5)
	sprite.region_rect.position = Vector2(variation[pick], 0)
	add_to_group("STACHE_GUYS")
	

func _physics_process(delta):
	velocity.y += gravity * delta
	velocity.x = 0
	
	if position.x < destination - 20:
		velocity.x += speed
	elif position.x > destination + 20:
		velocity.x -= speed
	else:
		var previous_value = int(counter_node.get_text())
		counter_node.set_text(str(previous_value + 1))
		queue_free()
		
	if randf() > 0.96 and is_on_floor():
		jump()
#		
	velocity = move_and_slide(velocity, Vector2.UP)

func jump():
	velocity.y -= JUMP_FORCE

func bullet_hit(position: Vector2, normal: Vector2):
	set_physics_process(false)
	queue_free()


func _on_Area2D_body_entered(body):
	if body.name == "Land" and is_on_floor():
		print_debug(body.name)
		jump()
