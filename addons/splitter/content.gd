tool
extends Control

const Utils = preload("utils.gd")

const LogicI = preload("logic_ii.gd")
var logic:LogicI
const TabsI = preload("splitter_ui/tabs_i.gd")

var id

var main_content:Control

func init(logic:LogicI, id):
	self.logic = logic
	self.id = id

	if id is Script:
#		main_content = Utils.find_child_by_type(self, TextEdit)
		main_content = self
		if !main_content.get_script():
			pass

	else:
		main_content = self
	
	if !main_content.is_connected("gui_input", self, 'on_main_content_gui'):
		main_content.connect("gui_input", self, 'on_main_content_gui')


func quit():
	if main_content.is_connected("gui_input", self, 'on_main_content_gui'):
		main_content.disconnect("gui_input", self, 'on_main_content_gui')


func on_main_content_gui(event:InputEvent):
	event = event as InputEventMouseButton
	if !event or not event.pressed: return
	if logic.ids_equal(id,logic.active_id):
		logic.open(id, true)
	elif logic.ids_equal(id,logic.inactive_id):
		logic.set_editor_active(logic.inactive_editor)
		logic.open(id, true)


func _notification(what):
	if what == NOTIFICATION_PREDELETE:

		logic.ids.erase(id)

		logic.on_content_predelete(self)
