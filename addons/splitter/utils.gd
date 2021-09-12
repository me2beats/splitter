static func find_child_by_type(node:Node, type)->Node:
	var result:Node
	for child in node.get_children():
		if child is type:
			result = child
			break
	return result


static func find_child_by_class(node:Node, cls:String)->Node:
	var result:Node
	for child in node.get_children():
		if child.get_class() == cls:
			result = child
			break
	return result


static func is_ancestor(node:Node, parent:Node)->bool:
	while node:
		node = node.get_parent()
		if node == parent:	return true
	return false


static func set_parent(node:Node, new_parent:Node, idx: = -1):
	if not new_parent: return # maybe this is not good

	var parent = node.get_parent()
	if parent:
		if parent == new_parent: return
		parent.remove_child(node)
	new_parent.add_child(node)
	if ! idx == -1:
		new_parent.move_child(node, idx)


static func find_node_by_class_path(node:Node, class_path:Array, keep_order: = true)->Node:
	var res:Node
	var stack = []
	var depths = []

	var first = class_path[0]
	for c in node.get_children():
		if c.get_class() == first:
			stack.push_back(c)
			depths.push_back(0)

	if not stack: return res
	
	var max_ = class_path.size()-1

	while stack:
		var d = depths.pop_back()
		var n = stack.pop_back()

		if d>max_:
			continue
		if n.get_class() == class_path[d]:
			if d == max_:
				res = n
				return res

			if keep_order:
				for i in range(n.get_child_count()-1,-1,-1):
					var c = n.get_child(i)
					stack.push_back(c)
					depths.push_back(d+1)
					
			else:
				for c in n.get_children():
					stack.push_back(c)
					depths.push_back(d+1)

	return res



static func get_script_tab_container(scr_ed:ScriptEditor)->TabContainer:
	return find_node_by_class_path(scr_ed, ['VBoxContainer', 'HSplitContainer', 'TabContainer']) as TabContainer
	
	
static func get_doc_index_in_tab_contaner(doc:String, script_editor_tab_container:TabContainer)->int:
	var title:String
	for i in script_editor_tab_container.get_tab_count():
		title = script_editor_tab_container.get_tab_title(i)
		if title == doc:
			return i
	return -1


static func get_script_item_list(script_ed:ScriptEditor)->ItemList:
	var script_item_list:ItemList = find_node_by_class_path(script_ed, [
		'VBoxContainer',
		'HSplitContainer',
		'VSplitContainer',
		'VBoxContainer',
		'ItemList'
	])
	return script_item_list	

	
	
static func get_code_editor(scr_text_ed:Container):
	return find_node_by_class_path(scr_text_ed, ['VSplitContainer', 'CodeTextEditor']) as BoxContainer


static func get_children_classes(node:Node)->Array:
	var result: = []
	for ch in node.get_children():
		result.push_back(ch.get_class())
	return result


static func get_children_names(node:Node)->Array:
	var result: = []
	for ch in node.get_children():
		result.push_back(ch.name)
	return result
