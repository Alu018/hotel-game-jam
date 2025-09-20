extends CanvasLayer

@onready var items_container = $MarginContainer/HBoxContainer  # This will hold all item icons
@onready var original_item_icon = $MarginContainer/HBoxContainer/ItemIcon  # Reference to copy settings
@onready var tooltip_panel = $TooltipPanel
@onready var tooltip_label = $TooltipPanel/TooltipLabel

# Modal elements - you'll need to add these to your scene
@onready var item_modal = $ItemModal  # Panel - set this as semi-transparent background
@onready var modal_item_icon = $ItemModal/VBoxContainer/ItemIcon  # Larger version of item icon
@onready var modal_title = $ItemModal/VBoxContainer/ItemTitle  # Label for item name
@onready var modal_description = $ItemModal/VBoxContainer/ItemDescription  # RichTextLabel for longer description
@onready var modal_close_button = $ItemModal/VBoxContainer/CloseButton  # Button to close modal

var item_icons: Array[TextureRect] = []  # Keep track of created icons

func _ready():
	tooltip_panel.visible = false
	item_modal.visible = false
	original_item_icon.visible = false
	
	# Connect close button
	modal_close_button.pressed.connect(_on_close_modal)
	
	# Clear any existing item icons
	clear_inventory_display()

func clear_inventory_display():
	# Remove all existing item icon nodes
	for icon in item_icons:
		if icon and is_instance_valid(icon):
			# Disconnect any existing signals before removing
			if icon.gui_input.is_connected(_on_item_clicked):
				icon.gui_input.disconnect(_on_item_clicked)
			icon.queue_free()
	item_icons.clear()

func update_inventory():
	# Clear existing display first
	clear_inventory_display()
	
	# Create an icon for each item in inventory
	for i in range(Inventory.items.size()):
		var item = Inventory.items[i]
		create_item_icon(item, i)

func create_item_icon(item, index: int):
	# Create new TextureRect by duplicating the original (keeps all settings)
	var item_icon = original_item_icon.duplicate()
	item_icon.texture = item.icon
	item_icon.visible = true
	
	# Add to container and track it
	items_container.add_child(item_icon)
	item_icons.append(item_icon)
	
	# Store item data for tooltip and modal
	item_icon.set_meta("item_data", item)
	
	# Connect click signal - bind the item data for easy access
	item_icon.gui_input.connect(_on_item_clicked.bind(item))

func _on_item_clicked(event: InputEvent, item):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		GameState.isViewingInventory = true
		open_item_modal(item)

func open_item_modal(item):
	# Hide tooltip when opening modal
	tooltip_panel.visible = false
	
	# Populate modal with item data
	modal_item_icon.texture = item.modalIcon
	
	# Fix the squashed sprite - set proper stretch and expand modes
	modal_item_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	modal_item_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# Set a good size for the modal icon (much larger than inventory)
	modal_item_icon.custom_minimum_size = Vector2(64, 64)
	
	modal_title.text = item.title if "name" in item else "Item"
	
	# Use long_description if available, otherwise use regular description
	var description = item.long_description if "long_description" in item else item.description
	modal_description.text = description
	
	# Show the modal
	item_modal.visible = true

func _on_close_modal():
	item_modal.visible = false
	GameState.isViewingInventory = false

func _process(delta):
	# Don't show tooltip if modal is open
	if item_modal.visible:
		tooltip_panel.visible = false
		return
		
	var mouse_pos = get_viewport().get_mouse_position()
	var tooltip_shown = false
	
	# Check each item icon for hover
	for icon in item_icons:
		if icon and is_instance_valid(icon) and icon.get_global_rect().has_point(mouse_pos):
			var item_data = icon.get_meta("item_data")
			tooltip_label.text = item_data.description
			tooltip_panel.global_position = mouse_pos + Vector2(-8, -tooltip_panel.size.y + 32)
			tooltip_panel.visible = true
			tooltip_shown = true
			break
	
	if not tooltip_shown:
		tooltip_panel.visible = false
		

#extends CanvasLayer
#@onready var item_icon = $MarginContainer/HBoxContainer/ItemIcon
#@onready var tooltip_panel = $TooltipPanel
#@onready var tooltip_label = $TooltipPanel/TooltipLabel
#func _ready():
	#item_icon.visible = false
	#tooltip_panel.visible = false
#func update_inventory():
	#if Inventory.items.size() > 0:
		#var item =       Inventory.items[Inventory.items.size() - 1]
		#print(Inventory.items)
		#item_icon.texture = item.icon
		#item_icon.visible = true
		#tooltip_label.text = item.description
	#else:
		#item_icon.visible = false
		#tooltip_panel.visible = false
#func _process(delta):
	#if item_icon.visible:
		#var mouse_pos = get_viewport().get_mouse_position()
		#if item_icon.get_global_rect().has_point(mouse_pos):
			#tooltip_panel.global_position = mouse_pos + Vector2(0, 16)
			#tooltip_panel.visible = true
		#else:
			#tooltip_panel.visible = false
