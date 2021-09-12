tool 
extends "tab_control_i.gd"

const Utils = preload("utils.gd")

const LogicI = preload("logic_ii.gd")
const TabsI = preload("splitter_ui/tabs_i.gd")

var logic:LogicI


func init(logic:LogicI):
	self.logic = logic

	update_content_info()


func update_content_info():
	id = logic.get_current_id()
	if not logic.is_id_type(id): return

	if id is Script:
		content_parent = Utils.get_code_editor(self)
		content = Utils.find_child_by_type(content_parent, TextEdit) as TextEdit
		
	else:
		content_parent = self
		content = Utils.find_child_by_type(self, RichTextLabel)

	content_idx = content.get_index()

	if id is Script:
		errorbar = Utils.find_child_by_class(content_parent, 'HBoxContainer')
		findbar = Utils.find_child_by_class(content_parent, 'FindReplaceBar')
	else:
		findbar = Utils.find_child_by_class(content_parent, 'FindBar')


	if id is Script:
		var splitter: = logic.splitter
		var context_menu:PopupMenu = Utils.find_child_by_class(self, 'PopupMenu')

		if not context_menu.is_connected("about_to_show", splitter, 'on_menu'):
			context_menu.connect("about_to_show", splitter, 'on_menu', [context_menu])





func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		
#		if not get('content'):
#			push_error('NO content!')
#			return
		
		if str(content) == '[Object:null]':
#			push_error('content is null!')
			return



		if content.get_parent():
			content.get_parent().remove_child(content)
		content.free()
		
		logic.ids.erase(id)

		logic.on_control_predelete(id)

