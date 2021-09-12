tool
extends PopupMenu

func _notification(what):
	if what == NOTIFICATION_PARENTED:
		get_parent().connect("gui_input", self, "on_parent_gui_input")

func on_parent_gui_input(event:InputEvent):
	event = event as InputEventMouseButton
	if not event or !event.pressed: return
	match event.button_index:
		BUTTON_RIGHT:
			rect_global_position = get_global_mouse_position()
			popup()
