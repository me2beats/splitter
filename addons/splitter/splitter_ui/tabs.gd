tool
extends "tabs_i.gd"

const LogicI = preload("../logic_i.gd")
var logic:LogicI

const TabsI = preload("tabs_i.gd")

var empty_texture:Texture
var empty_string:String

func init(logic:LogicI):
	self.logic = logic

	connect("tab_changed", self, "on_tab", [true])
	connect("tab_close", self, "close_pressed")


func close_pressed(tab:int):
	if not get_other_editor_tab_count() and get_tab_count() <=1:
		return

	remove_tab(tab, true)

	if not get_tab_count():
		logic.set_real_parent_by_editor(get_editor())
		
		logic.open(logic.active_id if !is_active() else logic.inactive_id)


func remove_tab(tab:int, force:= false):
	if not get_tab_count(): return

	var was_current = tab == current_tab
	
	.remove_tab(tab)
	tabs.remove(tab)

	if !get_tab_count():
		
		logic.recent_id = null
		#logic.recent_editor#?

		
		if is_active():
			logic.active_id = null
		else:
			logic.inactive_id = null
		return

#	if logic.quiet_tabs and not force: return


	if !get_tab_count():
#		logic.set_real_parent(get_editor())
		logic.set_real_parent_by_editor(get_editor())
		return


	if was_current:

		if is_active():
#			logic.open(tabs[current_tab], true)
			logic.open(tabs[current_tab])
		else:
			logic.set_content(tabs[current_tab], false)



func remove_tab_by_id(id):
	var tab: = tabs.find_last(id)
	if tab == -1: return
	remove_tab(tab)


func on_tab(tab:int, force: = false):
	if not get_tab_count(): return
#	if logic.quiet_tabs: return
	if !force or !logic.quiet_tabs:
		return
	logic.quiet_tabs = false

	var id = tabs[tab]
	


	if is_active():
		logic.open(id)
	else:
		logic.set_content(id, false)


	

func content_added(id):
	if ! logic.is_id_type(id): return
	var id_idx: = tabs.find_last(id)
	var tab:int
	match id_idx:
		-1:
			tab = get_tab_count()
			add_tab(logic.id2str(id))
			tabs.push_back(id)
		_:
			tab = id_idx

	current_tab = tab
	ensure_tab_visible(current_tab)


func get_editor():
	return get_parent().get_parent()


func get_other_editor()->Control:
	var editor = get_editor()
	return logic.active_editor if editor == logic.inactive_editor else logic.inactive_editor


func get_tabs(editor:Control)->Tabs:
	return editor.tabs as Tabs

func get_other_editor_tab_count()->int:
	return get_tabs(get_other_editor()).get_tab_count()


func move_current_tab_to_other_editor():

	if is_active():
		var id = logic.active_id

		logic.set_content(id, false)
		
		if !current_tab == -1:
			logic.open(tabs[current_tab])

	else:
		logic.open(logic.inactive_id, true)


# force_open -> force_on_tab ?
func remove_tab_from_other_editor(id, force_open:=false):
	var other_tabs:TabsI = get_tabs(get_other_editor())
	other_tabs.remove_tab_by_id(id)

	if force_open:
		other_tabs.on_tab(other_tabs.current_tab, true)



func is_active()->bool:
	return get_editor() == logic.active_editor

func _gui_input(event):
	event = event as InputEventMouseButton
	if not event or not event.pressed: return


	logic.quiet_tabs = false

	logic.set_editor_active(get_editor())


	if get_tab_count():
		logic.open(tabs[current_tab], true)

	match event.button_index:
		BUTTON_LEFT:
			pass
		BUTTON_MIDDLE:
			move_current_tab_to_other_editor()

	logic.quiet_tabs = true
