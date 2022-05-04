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
