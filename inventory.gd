extends Node

# Each item can be a dictionary with properties: name, icon, description
var items: Array = []

# Add an item
func add_item(item_data: Dictionary):
	if not has_item(item_data.name):
		items.append(item_data)
		InventoryUI.update_inventory()

# Remove an item by name
func remove_item(item_name: String):
	for i in range(items.size()):
		if items[i].name == item_name:
			items.remove_at(i)
			print("Removed: ", item_name)
			InventoryUI.update_inventory()
			return

# Check if an item exists
func has_item(item_name: String) -> bool:
	for item in items:
		if item.name == item_name:
			return true
	return false

# Get item info
func get_item(item_name: String) -> Dictionary:
	for item in items:
		if item.name == item_name:
			return item
	return {}
