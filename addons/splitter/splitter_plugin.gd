tool
extends EditorPlugin

const Logic = preload("logic.gd")
var logic:Logic

func _enter_tree():
	logic = Logic.new()
	logic.init(self)
	

func _exit_tree():
	logic.quit()

