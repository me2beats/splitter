tool
extends "logic_ii.gd"





const NULL_OBJECT_STRING = '[Object:null]'

const Utils = preload("utils.gd")

const ContentScript = preload("content.gd")

var item_list:ItemList



var plugin_scripts_readonly = false

# I got cases when is_instance_valid() didnt work
# UPD: surpriingly this function doesn't work too
# but str(control) == '[Object:null]' works :)
# todo: check this again.
func is_null_object(object:Object):
	return str(object) == NULL_OBJECT_STRING


func set_tab_control_script(control:Control):
	if control.get_script(): return
	var path = "res://addons/splitter/tab_control.gd"
	control.set_script(load(path))
	control = control as TabControlI
	control.init(self)



func init_splitter():
	splitter = preload("splitter_ui/splitter.tscn").instance()

	splitter.init(self)

	script_editor.add_child(splitter)
	
	var hsplit:HSplitContainer = splitter.get_node("HSplitContainer")

	set_hsplit_pos_and_size(hsplit)

	tab_container.connect("resized", self, 'on_tab_container_resized')

	init_tabs(active_editor)
	init_tabs(inactive_editor)



func on_tab_container_resized():
	var hsplit:HSplitContainer = splitter.get_node("HSplitContainer")
	set_hsplit_pos_and_size(hsplit)

func set_hsplit_pos_and_size(hsplit:HSplitContainer):
	hsplit.set_global_position(tab_container.rect_global_position)
	hsplit.rect_size = tab_container.rect_size
	

func update_current_id(tab_control:TabControlI):
	var id = get_current_id()

	var recent_control:Control = ids.get(id)
	if !recent_control:
		ids[id] = tab_control


func set_content_script(content:Control, id):
	if !is_id_type(id): return

	var path = "res://addons/splitter/content.gd"
	content.set_script(ContentScript)
	content = content as ContentScript
	
	content.init(self, id)
	


func update_selected():
	yield(plugin.get_tree(),"idle_frame")
	yield(plugin.get_tree(),"idle_frame")
	item_list.ensure_current_is_visible()


func on_tab(tab:int):
	update_selected()

	var control = tab_container.get_tab_control(tab)
	set_tab_control_script(control)

	control = control as TabControlI
	var id = get_current_id()
	set_content_script(control.content, id)
	update_current_id(control)

	
#	item_list.unselect_all()
#	item_list.select(tab)
#	item_list.max_columns = 2 # :)
#	item_list.select(tab_container.current_tab)



	if quiet: return

	set_content(id)

	if tab_container.get_tab_count() and not splitter.visible:
		splitter.visible = true





func init(plugin:EditorPlugin):
	
	self.plugin = plugin	
	script_editor = plugin.get_editor_interface().get_script_editor()
	tab_container = Utils.get_script_tab_container(script_editor)
	tab_container.connect("tab_changed", self, "on_tab")
	item_list = Utils.get_script_item_list(script_editor)

	remove_attached_scripts()

	init_splitter()



func init_tabs(editor:Control):
	var tabs:TabsI = editor.tabs
	tabs.init(self)


func set_real_parent_by_editor(editor:Control):
	
	# get editor content?
	if not editor.get_node('ContentParent').get_child_count(): return
	var old_content:ContentScript = editor.get_node('ContentParent').get_child(0)
	if not old_content: return
	var old_content_id = old_content.id
	set_real_parent(old_content_id)
	

func get_content_by_id(id)->ContentScript:
	var empty: ContentScript
	if not id: return empty
	var control:TabControlI = ids.get(id)
	
	if not control: return empty
	return control.content as ContentScript


func ids2strings(ids:Array)->PoolStringArray:
	var result = PoolStringArray()
	for id in ids:
		result.push_back(id2str(id))
	return result



# bars mean findbar and errorbar
func set_bars_real_parent(id):
	var control:TabControlI = ids.get(id)
	if not  control: return

	var findbar:Control = control.findbar
	var errorbar:Control = control.errorbar
	
	var parent:Control = control.content_parent
	
	if findbar:	Utils.set_parent(findbar, parent)
	if errorbar:Utils.set_parent(errorbar, parent)
	



func are_bars_parents_empty(editor:Control):
	return !editor.get_node("ErrorBarParent").get_child_count()\
	and !editor.get_node("FindBarParent").get_child_count()


func quit():

	set_real_parent(active_id)
	set_real_parent(inactive_id)
	
	# just for extra safety
	set_real_parent_by_editor(active_editor)
	set_real_parent_by_editor(inactive_editor)


#	set_bars_real_parent(active_id)
#	set_bars_real_parent(inactive_id)


	if !are_bars_parents_empty(active_editor)\
	or !are_bars_parents_empty(inactive_editor):
		push_error("quit: some bars are still in Editor!")


	if plugin_scripts_readonly:
		set_read_only(get_content_by_id(active_id), false)
		set_read_only(get_content_by_id(inactive_id), false)

		set_read_only(get_editor_content(active_editor), false)
		set_read_only(get_editor_content(inactive_editor), false)

	# queue_free() hangs the editor (in early versions tho)
	splitter.free() 
	tab_container.disconnect("tab_changed", self, "on_tab")
	remove_attached_scripts()




# not beautiful way to compare 2 values which may be of different types
func ids_equal(id1, id2)->bool:
	if id1 is Script and id2 is String or id1 is String and id2 is Script:
		return false
	return id1==id2


func remove_attached_scripts():
	for i in tab_container.get_tab_count():
		var tab_control:Control = tab_container.get_tab_control(i)
		if tab_control.get_script():
			tab_control = tab_control as TabControlI
			if not tab_control:
				return

			var content = tab_control.content
			if content and content.get_script():
				content.quit()
				content.set_script(null)
				
			tab_control.set_script(null)
		

func id2str(id)->String:
	if not id: return ''
	return id if id is String else id.resource_path.get_file()




# id vs tab control?
func set_real_parent(id):
	

	if not is_id_type(id, false): return

	if !ids.has(id):
		return

	var control:TabControlI = ids[id]


	if not control:
#		push_error('control is not found for: '+id2str(id))
		return


	if str(control) == '[Object:null]':
		push_error('control is null! '+ str(control))
		return

#	var content:Control = control.content
	var content:Control = control.get('content')
	
	if not content:
		push_error('content is not found for: '+id2str(id))
		return



	var parent:Control = control.content_parent
	if not parent:
		push_error('parent is not found for: '+id2str(id))
		return

	var idx:int = control.content_idx


	Utils.set_parent(content, parent, idx)


	set_bars_real_parent(id)


func get_other_id(id):
	return inactive_id if ids_equal(id, active_id) else active_id

# only for Script ids
func get_main_content(id:Script):
	var tab_control = ids.get(id)
	if not tab_control: return
	tab_control = tab_control as TabControlI
	if not tab_control: return
	var main_content = tab_control.content.main_content as TextEdit
	return main_content

func open(id, force:= false):
	if ! is_id_type(id): return
	
	if !force and ids_equal(id, active_id):
#		push_error('ids equal')
		return

	if id is Script:
		open_script(id)
		
		var recent_quiet = quiet
		open_script(id)

		var other_id = get_other_id(id)
		if other_id:
			pass


	else:
		open_doc(id)


func set_editor_active(editor:Control):
	if editor == active_editor: return
	
	inactive_editor = active_editor
	active_editor = editor

	var buffer = active_id
	active_id = inactive_id
	inactive_id = buffer

	emit_signal("active_editor_changed", active_editor)

	

func open_script(script:Script):
	plugin.get_editor_interface().edit_resource(script)


# need to check if doc is already exist
# otherwise new items(tabs) can be created and we don't want it
func open_doc(doc:String):
	var doc_idx: = Utils.get_doc_index_in_tab_contaner(doc, tab_container)
	if doc_idx == -1:
		script_editor._help_class_open(doc)
	else:
		# this part is hacky and ugly
		# can this be dangerous?
		tab_container.current_tab = doc_idx
		var item_list:ItemList = Utils.get_script_item_list(script_editor)
		tab_container.emit_signal("tab_changed", doc_idx)
		item_list.select(doc_idx)
		item_list.emit_signal("item_selected", doc_idx)


func set_read_only(content:Control, enable:=true):
	if !content is Container: return
	if not content: return

	var id =  content.get('id') as Script
	if not id: return

	# override get_class()
	content = content as ContentScript
	if not content: return
	
#	var text_edit:TextEdit = Utils.find_child_by_type(content, TextEdit)
	var text_edit:TextEdit = content
	
	text_edit.readonly = enable


# TODO: mb better to have it in editor script
func get_editor_content(editor:Control)->ContentScript:
	var empty:ContentScript
	if not editor: return empty
	var content_parent = editor.get_node('ContentParent')
	if not content_parent.get_child_count(): return empty
	return content_parent.get_child(0) as ContentScript


func set_content(id, set_to_active:=true, move_from_other:=false):
	if not is_id_type(id): return
	
	var editor:Control = active_editor if set_to_active else inactive_editor
	if ids_equal(id, recent_id) and editor == recent_editor: return

	if set_to_active and ids_equal(id, active_id): return


	if !set_to_active and ids_equal(id, inactive_id): return


	var control:TabControlI = ids.get(id)
	if not control:
		push_error('no control')
		return

	var content:Control = control.content
	var parent:Control = control.content_parent
	var idx:int = control.content_idx

	var tabs:TabsI = editor.tabs
	

	if !move_from_other and set_to_active:
		var inactive_editor_tabs:TabsI = inactive_editor.tabs
		if id in inactive_editor_tabs.tabs:
			set_content(id, false)
			return


	



	var old_content = get_editor_content(editor)
	var old_content_id

	if old_content:
		# remove old content
		old_content_id = old_content.id
		if old_content_id:
			set_real_parent(old_content_id)
		
		if plugin_scripts_readonly:
			set_read_only(old_content, false)

	if plugin_scripts_readonly:
		set_read_only(content, true)

	var content_parent:Control = editor.get_node("ContentParent")
	Utils.set_parent(content, content_parent)


	
	#====== add errorbar and findbar =======
	var old_parent
	if old_content_id:
		var old_control:TabControlI = ids.get(old_content_id)
		if old_control:
			old_parent = old_control.content_parent

	var findbar:Control = control.findbar
	var errorbar:Control = control.errorbar
	
	var findbar_parent = editor.get_node('FindBarParent')
	var errorbar_parent = editor.get_node('ErrorBarParent')
	

	# maybe create Utils.clear_children()?
	if findbar_parent.get_child_count():
		var old_findbar = findbar_parent.get_child(0)
		Utils.set_parent(old_findbar, old_parent)

	if errorbar_parent.get_child_count():
		var old_errorbar = errorbar_parent.get_child(0)
		Utils.set_parent(old_errorbar, old_parent)
	

	if findbar:
#		findbar.rect_min_size = findbar.rect_size
		Utils.set_parent(findbar, findbar_parent)
	
	if errorbar:
#		errorbar.rect_min_size = errorbar.rect_size
		Utils.set_parent(errorbar, errorbar_parent)

	#=========================================



	if set_to_active:active_id = id
	else: inactive_id = id
	
	tabs.content_added(id)


	recent_editor = editor
	recent_id = id

	tabs.remove_tab_from_other_editor(id, true)
	


func get_script_content_real_parent(tab_control:Control)->Control:
#	return Utils.find_child_by_type(tab_control, VSplitContainer) as Control
	return Utils.get_code_editor(tab_control) as BoxContainer

func get_doc_content_real_parent(tab_control:Control)->Control:
	return tab_control


func get_current_id():
	var cur_script = script_editor.get_current_script()
	if cur_script:
		return cur_script
	else:
		return get_current_doc_class()


func get_current_doc_class()->String:
	if tab_container.current_tab>=tab_container.get_tab_count(): return ''
	return tab_container.get_tab_title(tab_container.current_tab)



func is_id_type(id, push_err:=true)->bool:
	if not id: return false
	if not (id is Script or id is String):
		if push_err:
			push_error('not supported id type '+str(id))
		return false
	return true


func on_control_or_container_predelete(id):
#	set_content(get_current_id())
	yield(plugin.get_tree(), "idle_frame")

	var active_tabs:TabsI = active_editor.tabs
	active_tabs.remove_tab_by_id(id)
	var inactive_tabs:TabsI = inactive_editor.tabs
	inactive_tabs.remove_tab_by_id(id)

	open(get_current_id()) #?? not active ? 
	if not tab_container.get_tab_count():
		splitter.visible = false


func on_content_predelete(content:Control):
	var id = content.id
#	print("content predelete")
	on_control_or_container_predelete(id)


func on_control_predelete(id):
#	print("control predelete")
	on_control_or_container_predelete(id)



