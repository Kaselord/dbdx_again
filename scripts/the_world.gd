extends Node2D


func _ready():
	worldgen()


func worldgen():
	# write to res:// if this is the debug build inside the editor, write to executable path if not
	var path : String = "res://"
	if !OS.has_feature("editor"):
		path = OS.get_executable_path() + "/"
	var naming_index : int = 0
	while FileAccess.file_exists(path + "world" + str(naming_index) +  ".dat"):
		naming_index += 1
	var world_file = FileAccess.open(path + "world" + str(naming_index) +  ".dat", FileAccess.WRITE)
	
	
	
	world_file.close()
