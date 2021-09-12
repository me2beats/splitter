tool
extends VBoxContainer

var tabs:Tabs
var panel:PanelContainer
var other_panel:PanelContainer

var logic:Reference

func init(logic:Reference):
	panel = $PanelContainer
	tabs = $PanelContainer/Tabs
	self.logic = logic


# mb not needed
func get_other_editor()->Container:
	return get_parent().get_child(1-get_index()) as Container


func highlight():
	panel.set('custom_styles/panel', preload("active_editor.tres"))
	other_panel.set('custom_styles/panel', preload("inactive_editor.tres"))
