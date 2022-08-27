extends Node2D

var max_ufos = 24
var ufo_count = 0

export (PackedScene) var miniUFO
export (PackedScene) var bigBomb

func boss_killed():
	$BigBombTimer.stop()
	$SpawnUFOTimer.stop()
	$T1.queue_free()
	$T2.queue_free()
	$T3.queue_free()

func _ready():
	$SpawnUFOTimer.start()

func _on_SpawnUFOTimer_timeout():
	$SpawnUFOTimer.wait_time = rand_range(12, 18)
	if ufo_count >= max_ufos:
		return
	var ufo = miniUFO.instance()
	var spawns = [$T1, $T2, $T3]
	var spawn = spawns[floor(rand_range(0, len(spawns)))]
	spawn.add_child(ufo)
	ufo.owner = self
	ufo.global_position = Vector2(rand_range(spawn.get_node("UfoLeft").global_position.x, spawn.get_node("UfoRight").global_position.x), spawn.get_node("UfoLeft").global_position.y) 
	ufo.left_target = spawn.get_node("UfoLeft").global_position
	ufo.right_target = spawn.get_node("UfoRight").global_position

var thrown_bombs = 0
var barrage_size = 4
func _on_BigBombTimer_timeout():
	$SpawnUFOTimer.wait_time = rand_range(12, 20)
	$BombBarrage.start()
	thrown_bombs = 0
	barrage_size = rand_range(3, 6)

func _on_BombBarrage_timeout():
	if thrown_bombs < barrage_size:
		thrown_bombs += 1
		var bomb = bigBomb.instance()
		add_child(bomb)
		bomb.global_position = $BombSpawnPosition.global_position
		$BombBarrage.start()
