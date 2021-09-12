tool

# may be also implemented as a setter
signal active_editor_changed(active_editor)

var plugin:EditorPlugin

var script_editor:ScriptEditor
var tab_container:TabContainer

const TabControlI = preload("tab_control_i.gd")

# recently opened
var recent_id
var recent_editor:Control

var quiet: = false
var quiet_tabs: = true


var active_editor:Control
var inactive_editor:Control

var active_id
var inactive_id

var ids: = {}

func set_tab_control_script(control:Control):
	pass

func ids_equal(id1, id2)->bool:
	return false

func open(id, force:= false):
	pass

func init_splitter():
	pass	

func init(plugin:EditorPlugin):
	pass


func quit():
	pass

# id vs tab control?
func set_real_parent(id):
	pass

func set_real_parent_by_editor(editor:Control):
	pass

func set_content(id, set_to_active:=true, remove_from_other:=false):
	pass

func id2str(id)->String:
	return ''

func get_script_content_real_parent(tab_control:Control)->Control:
	var nul:Control
	return nul

func get_doc_content_real_parent(tab_control:Control)->Control:
	var nul:Control
	return nul

func get_current_id():
	pass

func is_id_type(id)->bool:
	return false


func on_content_predelete(content:Control):
	pass


func set_editor_active(editor:Control):
	pass

