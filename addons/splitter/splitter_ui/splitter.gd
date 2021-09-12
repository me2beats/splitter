tool
extends "splitter_i.gd"

const Utils = preload("../utils.gd")

var editor1:Control
var editor2:Control


func _notification(what):
	if what == NOTIFICATION_PREDELETE:
#		print("splitter predelete!")
		set_script(null)



func init(logic:LogicI):
	self.logic = logic
	
	
	editor1 = $HSplitContainer/Editor1
	editor2 = $HSplitContainer/Editor2
	
	
	logic.active_editor = editor1
	logic.inactive_editor = editor2
	
	editor1.init(logic)
	editor2.init(logic)

	editor1.other_panel = editor2.panel
	editor2.other_panel = editor1.panel
	

	logic.connect("active_editor_changed", self, "on_editor_changed")
	editor1.highlight()


func on_editor_changed(active_editor):
	active_editor.highlight()



func on_menu(menu:PopupMenu):
	menu.rect_global_position =get_global_mouse_position()
