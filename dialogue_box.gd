extends Node2D

signal dialogue_finished

# dialogueLines is array of dictionaries
var dialogueLines = []
var currentLine = 0
var isActive = false
var npcName: String = ""
var isTalking: bool = false

var typing_speed = 0.02  # Time between each character (adjust for speed)
var is_typing = false    # Track if text is currently being typed
var full_text = ""       # Store the complete text to display
var current_char_index = 0  # Track current character position
var typing_timer = 0.0   # Timer for character display

#@onready var oldLadyWalkOut = %OldLady.get_node("WalkOut")
@onready var node_journal = %Journal
@onready var winePetrusNoir = %WinePetrusNoir

var oldLadyWalkOut: Node = null

# INVENTORY ITEMS
var room_key = {
	"name": "room_key",
	"title": "Hotel Room 9 Key",
	"icon": preload("res://inventory/hotel-key-card.png"),
	"modalIcon": preload("res://inventory/hotel-key-card.png"),
	"description": "Inspect",
	"long_description": "The key to room 9. Apparently, belongs to someone named M, who never arrived."
}

var flash_drive = {
	"name": "flash_drive",
	"title": "Flash Drive",
	"icon": preload("res://inventory/flash_drive.png"),
	"modalIcon": preload("res://inventory/flash_drive.png"),
	"description": "Inspect",
	"long_description": "Plug into a computer to view its contents."
}

var business_card = {
	"name": "business_card",
	"title": "Business Card",
	"icon": preload("res://inventory/business_card.png"),
	"modalIcon": preload("res://inventory/business_card.png"),
	"description": "Inspect",
	"long_description": "There's a number on the card. I can call it if I can find a phone."
}

var picture = {
	"name": "picture",
	"title": "Picture of tree",
	"icon": preload("res://inventory/picture_clue.png"),
	"modalIcon": preload("res://inventory/modal-pics/modalPic-tree.png"),
	"description": "Inspect",
	"long_description": "A picture of what seems to be a tree in an outdoor area."
}

var glasses = {
	"name": "glasses",
	"title": "Glasses",
	"icon": preload("res://inventory/glasses.png"),
	"modalIcon": preload("res://inventory/glasses.png"),
	"description": "Inspect",
	"long_description": "An old pair of glasses. They look worn and weathered."
}

var label = {
	"name": "label",
	"title": "Wine Bottle Label",
	"icon": preload("res://inventory/bottle-label.png"),
	"modalIcon": preload("res://inventory/bottle-label.png"),
	"description": "Inspect",
	"long_description": "A label for a wine bottle. It reads 'Pétrus Noir'."
}
var paper_clue_1 = {
	"name": "paper_clue_1",
	"title": "Slip of Paper",
	"icon": preload("res://inventory/sticky-note-left.png"),
	"modalIcon": preload("res://inventory/sticky-note-left.png"),
	"description": "Inspect",
	"long_description": "The left side of a ripped piece of paper. The number '53' is written on it."
}
var paper_clue_2 = {
	"name": "paper_clue_2",
	"title": "Slip of Paper",
	"icon": preload("res://inventory/sticky-note-right.png"),
	"modalIcon": preload("res://inventory/sticky-note-right.png"),
	"description": "Inspect",
	"long_description": "The right side of a ripped piece of paper. The number '91' is written on it."
}

var m_journal = {
	"name": "m_journal",
	"title": "M's Journal",
	"icon": preload("res://inventory/m-journal.png"),
	"modalIcon": preload("res://inventory/m-journal.png"),
	"description": "Inspect",
	"long_description": "M's Journal. It details their plan to find the dark wine bottle and swap the label with the Pétrus Noir label."
}
var wine_cellar_key = {
	"name": "wine_cellar_key",
	"title": "Key to Wine Cellar",
	"icon": preload("res://inventory/wine-cellar-key.png"),
	"modalIcon": preload("res://inventory/wine-cellar-key.png"),
	"description": "Inspect",
	"long_description": "The key to the wine cellar of the hotel."
}
var wine_petrus_noir = {
	"name": "wine_petrus_noir",
	"title": "Pétrus Noir Wine",
	"icon": preload("res://inventory/wine-petrus-noir.png"),
	"modalIcon": preload("res://inventory/wine-petrus-noir.png"),
	"description": "Inspect",
	"long_description": "A bottle of wine with a label that reads Pétrus Noir. The mystery man is waiting for this in Room 3."
}

# --- Dialogue data ---
@onready var text_monologue = [
	{"text": "April 19th, 20XX.", "choices": []},
	{"text": "Last week, I had one of the strangest experiences of my life.", "choices": []},
	{"text": "I had been hitchiking for three days, exhausted and desperate for shelter from the rain.", "choices": []},
	{"text": "... when all of a sudden, I came across a small hotel on the side of the road.", "choices": []},
	{"text": "I had no money, but I was also out of options. I thought it wouldn't hurt to see if I could get a room.", "choices": []},
	{"text": "And so I did, though I'm not proud of what I did to acquire said accomodation.", "choices": []},
	{"text": "But, suffice to say, it led me to a bizarre night.", "choices": []},
	{"text": "It all started one stormy afternoon...", "choices": []},
]

@onready var text_concierge_q0 = [
	{"text": "Hello, and welcome to our charming hotel! How can I help you?", "choices": []},
	{"text": "Are you looking for a room with us?", "choices": [
		{"text": "Yes", "next_line": 2}
	]},
	
	{"text": "Unfortunately, every room here is booked for the next week...", "choices": []},
	{"text": "Unless you already made a reservation at the hotel, we won’t be able to accept walk-ins.", "choices": []},
	{"text": "So... do you have a reservation?", "choices": [
		{"text": "Yes (lie)", "next_line": 5}
	]},
	
	{"text": "Oh! Well, in that case, let's get you checked in.", "choices": []},
	{"text": "Hmm... let's see here...", "choices": []},
	{"text": "Hold on a second... the only guest who hasn't checked in is the guest for Room 9.", "choices": []},
	{"text": "...", "choices": []},
	{"text": "Oh my goodness! You're the guest we've been waiting for! I'm so sorry, I didn't recognize you.", "choices": []},
	{"text": "It says here your name is... M? Just M?", "choices": []},
	{"text": "We heard that you were going to arrive around this time. Thank you so much for your patronage - and please know you are our valued guest.", "choices": []},
	{"text": "Before I direct you to your room, let me go through some of our amenities here at the hotel.", "choices": []},
	{"text": "We have ten beautiful rooms here, each fitted with a plush bed and full bath for a restful night.", "choices": []},
	{"text": "In addition, we have our newly renovated Recreation Room to your left, for all your media and entertainment needs.", "choices": []},
	{"text": "And on the north side of the hotel, we just finished construction on our outdoor Courtyard if you need a breath of fresh air and greenery.", "choices": []},
	{"text": "With that, here is your room key to Room 9, on your right.", "choices": []},
	{"text": "Please enjoy your stay here, Patron M.", "choices": []},
	{"text": "[An item was just added to your inventory on the top left!]", "choices": []},
]

@onready var text_concierge_q1 = [
	{"text": "My deepest apologies yet again... we greatly appreciate your patronage.", "choices": []},
	{"text": "You'll find that your room is completely set up for you already.", "choices": []}
]

@onready var text_concierge_q2 = [
	{"text": "Oh hello, patron M. What can I do for you?", "choices": [
		{"text": "Wine cellar?", "next_line": 1}
	]},
	
	{"text": "Ah, yes... our valuable wine collection at the hotel.", "choices": []},
	{"text": "If I remember correctly, you've stored a number of rare wines there yourself.", "choices": []},
	{"text": "...oh? You'd like to access it? That's no trouble at all. You'll just need your cellar key.", "choices": [
		{"text": "Cellar key?", "next_line": 4}
	]},
	
	{"text": "Well... yes. I'm so sorry, I thought you remembered?", "choices": []},
	{"text": "Since the wine cellar here stores such a valuable collection, we require each guest to have their own personal key.", "choices": []},
	{"text": "On top of that, I have to approve access to the cellar from the hotel's side through our system.", "choices": []},
	{"text": "If you are missing your key or any other items, your luggage just arrived this morning.", "choices": []},
	{"text": "I had our bellhop bring it to your room, so you may want to check there.", "choices": []},
]

@onready var text_concierge_q3 = [
	{"text": "Your suitcase just arrived and should be in your room.", "choices": []},
	{"text": "And as I mentioned, for the wine cellar you'll need your personal cellar key.", "choices": []},
	{"text": "Perhaps you stored it in your room safe?", "choices": []}
]
@onready var text_concierge_default = [
	{"text": "Hello, Patron M. Please let me know if there's anything I can help you with.", "choices": []}
]

@onready var text_concierge_q4_phone = [
	{"text": "Hello, Patron M - how can I help you?", "choices": [
		{"text": "Room phone?", "next_line": 1}
	]},
	
	{"text": "Ah, yes if you need to call someone, you may use the phone in your room.", "choices": []},
	{"text": "...oh? It's not working, you say?", "choices": []},
	{"text": "Hmmm... let me think...", "choices": []},
	{"text": "Well, if you are dire need of a phone, you can feel free to use the phone in Room 4.", "choices": []},
	{"text": "The guest there just checked out, and we're preparing the room for the next guest tonight, so please do be quick.", "choices": []},
]
@onready var text_concierge_q4_phoneAsked = [
	{"text": "You can use the phone in Room 4. However, do be quick as we need to prepare the room for our next guest.", "choices": []}
]
@onready var text_concierge_q5 = [
	{"text": "Ah... Patron M. A delight as always. How can I assist you?", "choices": [
		{"text": "I have the key", "next_line": 1}
	]},
	
	{"text": "Ah! The key to the wine cellar, of course. Glad you found it.", "choices": []},
	{"text": "I've just approved the cellar to be unlocked through our system. Now you should be able to open it with your personal key.", "choices": []},
]
@onready var text_concierge_q5_cellarUnlocked = [
	{"text": "The wine cellar is approved to be unlocked by you. Please enjoy your collection of fine wines.", "choices": []}
]

@onready var text_greeter = [
	{"text": "Hello!", "choices": []},
	{"text": "Welcome to our lovely hotel, where comfort is our number one priority.", "choices": []},
	{"text": "If you're looking to check in, the concierge is just up ahead.", "choices": []}
]

@onready var text_bellhop_1 = [
	{"text": "Sorry, but you can't come in yet.", "choices": []},
	{"text": "Please check in with the Concierge at the front desk first.", "choices": []}
]

@onready var text_bellhopR_2 = [
	{"text": "Oh! I'm... I'm so sorry I didn't recognize you earlier...", "choices": []},
	{"text": "Your room is right this way.", "choices": []}
]
@onready var text_bellhopL_2 = [
	{"text": "My sincere apologies... we didn't realize it was you.", "choices": []},
	{"text": "If you need any help with your items, please let me know.", "choices": []}
]

@onready var text_bellhop_default = [
	{"text": "If you need any help, please ask the concierge for assistance.", "choices": []}
]

@onready var text_gangLeader_q1 = [
	{"text": "Well, well, well...", "choices": []},
	{"text": "If it isn't our esteemed guest...", "choices": []},
	{"text": "The famous, rich, honorable... M.", "choices": []},
	{"text": "It's good to finally meet you in person, M. Nice to match a face to a name.", "choices": []},
	{"text": "You remember me, right? I hope you didn't forget what I helped you with.", "choices": []},
	{"text": "Now... I held up my end of the deal. But I'm still waiting on you to hold up your end.", "choices": [
		{"text": "Deal?", "next_line": 6}
	]},
	
	{"text": "Don't act like you don't remember.", "choices": []},
	{"text": "I'm not someone you want to betray... I can make your life very difficult.", "choices": []},
	{"text": "As a person of your status, this would not be easy... but not impossible.", "choices": []},
	{"text": "So this would be simpler for both of us if you just get me the item I require.", "choices": [
		{"text": "Item?", "next_line": 10}
	]},
	
	{"text": "Yes, M... the item you promised me. For someone like you, I figure you'd have them just lying around.", "choices": []},
	{"text": "An object of decadence, of richness, of luxury... the Pétrus Noir.", "choices": []},
	{"text": "...", "choices": []},
	{"text": "...you know, the bottle of wine?", "choices": []},
	{"text": "Anyway...", "choices": []},
	{"text": "You have until the end of the day. if you don't have the wine by then... there's gonna be trouble.", "choices": []},
	{"text": "Once you have it, come to room 3.", "choices": []},
	{"text": "I'll be waiting.", "choices": []}
]
@onready var text_gangLeader_q2 = [
	{"text": "... why are you here?", "choices": []},
	{"text": "I told you, you have the end of the day to bring me the Pétrus Noir wine you promised.", "choices": []},
	{"text": "You had better hold up your end of the deal, M.", "choices": []},
]
@onready var text_gangLeader_q7 = [
	{"text": "Ah... M.", "choices": []},
	{"text": "You're just in time. I was about to send my men after you.", "choices": []},
	{"text": "You have something for me?", "choices": [
		{"text": "(Give wine)", "next_line": 3}
	]},
	
	{"text": "Ah... the elusive Pétrus Noir. How long I've waited for this treasure.", "choices": []},
	{"text": "Well... no time like the present.", "choices": []},
	{"text": "*POP*", "choices": []},
	{"text": "*GLUG* *GLUG* *GLUG*", "choices": []},
	{"text": "...", "choices": []},
	{"text": "... .....", "choices": []},
	{"text": "... the richness... the decadence...", "choices": []},
	{"text": "... I've never tasted anything quite like this.", "choices": []},
	{"text": "M...", "choices": []},
	{"text": "Our business is complete.", "choices": []},
	{"text": "I'm sure we'll meet again in the future.", "choices": []},
]
@onready var text_gangLeader_q8 = [
	{"text": "Our business is complete, M.", "choices": []},
	{"text": "I'm sure we'll meet again in the future.", "choices": []},
]


# old lady
@onready var text_old_lady_q1 = [
	{"text": "This computer is so hard to use...", "choices": []},
	{"text": "Hmm...", "choices": []},
]

@onready var text_old_lady_q4 = [
	{"text": "Ohh... hello dear...", "choices": []},
	{"text": "I'm sorry... did you need to use the computer?", "choices": []},
	{"text": "I'm trying to read an email from my son - he's visiting me from across the country.", "choices": []},
	{"text": "My son's a very important man you know. The hotel staff all know him.", "choices": []},
	{"text": "Anyway... the text is so small, I can't make out what any of the letters are. I've been trying to zoom in for almost an hour now.", "choices": []},
	{"text": "*Sighhh* ... if only I had my reading glasses from my room, I could see this.", "choices": []},
	{"text": "But Room 7 is so far away... I'll give this one more shot.", "choices": []},
]
@onready var text_old_lady_q4_gotGlasses = [
	{"text": "Hello again, dear... wh-", "choices": []},
	{"text": "...oh my. Are those my glasses? Oh dear, you shouldn't have gone all the way. That's so sweet of you.", "choices": []},
	{"text": "[Takes glasses] Ah! Much better. Goodness, I can finally see the screen now.", "choices": []},
	{"text": "Now, let's see here.", "choices": []},
	{"text": "What did my son say in his email?", "choices": []},
	{"text": "'Hi Mom, hope you're doing well. Just wanted to say that I'll be quite late arriving at the hotel. So sorry to keep you waiting.'", "choices": []},
	{"text": "'Some things have come up and... I'm in a bit of trouble...'", "choices": []},
	{"text": "'I'm also having trouble remembering things, which is why I'm sending you this message now before I forget.'", "choices": []},
	{"text": "'But don't worry about me, I'll be ok. See you soon.'", "choices": []},
	{"text": "'Love, Maxwell'", "choices": []},
	{"text": "...", "choices": []},
	{"text": "Oh, my darling Maxwell... he's always had a tough time in life. He's much like you, actually... I think you two would get along.", "choices": []},
	{"text": "Oh! I'm so sorry - you were waiting for the computer. Please do go ahead. I had better go rest now, anyway.", "choices": []},
]

# associate
@onready var text_associate_q4_1 = [
	{"text": "What the- you're not M. Who the hell are you?", "choices": []},
	{"text": "Wait a sec... are you working for that idiot too?", "choices": []},
	{"text": "Y'know what? I don't even care. This has been one of the most exhausting jobs I’ve ever done.", "choices": []},
	{"text": "M gave me this, without any context. Told me to hold on to it until I get a call.", "choices": []},
	{"text": "Just take it, alright?", "choices": []},
]
@onready var text_associate_q4_2 = [
	{"text": "I've done a lotta jobs in my time... but this one takes the cake.", "choices": []},
	{"text": "Anyway, I'm tired. So just get outta here, all right?", "choices": []},
	{"text": "I don't know what happened to M, but I know what's gonna happen to you if you don't.", "choices": []},
]
@onready var text_associate_playerBlocker = [
	{"text": "...", "choices": []},
	{"text": "...go away, please. I'm busy.", "choices": []}
]

# ----- NAMES ------ 
@onready var interactableNames = {
	"GangLeader": "Mystery Man",
	"BellhopL": "Bellhop",
	"BellhopR": "Bellhop",
	"Sign_MainRight": "Sign",
	"Sign_MainLeft": "Sign",
	"Sign_MainUp": "Sign",
	"OldLady": "Old Lady",
	"ComputerPrinterTable": "Computer 3",
	"ComputerTableBroken": "Computer 1",
	"ComputerTableBroken2": "Computer 2",
	"Phone_Room4": "Phone",
	"Associate": "M's Associate",
	"RedTree": "Tree",
	"PlayerBlocker_Room8": "???",
	"WineCellarDoor": "[Cellar Door]",
	"WinePetrusNoir": "Player [with wine]",
	"CourtyardPerson": "Hotel Guest",
	"Room2_Dad": "Hotel Guest",
	"Room2_Mom": "Hotel Guest",
	"Room2_Kid": "Hotel Guest",
	"PaintingAdmirer": "Hotel Guest",
	"BathroomGuy": "Hotel Guest",
	"PlayerBed": "Bed",
	"SleepNode": "---"
}

# ------ ITEMS -------
@onready var text_sign_mainRight = [
	{"text": "\nWINE CELLAR* -->\n<-- LOBBY", "choices": []},
	{"text": "*Please inquire about wine cellar at the concierge", "choices": []},
]

@onready var text_sign_mainLeft = [
	{"text": "\n<-- REC ROOM*\nLOBBY -->", "choices": []},
	{"text": "*Want to relax or use the computer? Try our newly, refurbished recreation room!", "choices": []},
]
@onready var text_sign_mainUp = [
	{"text": "Courtyard - up ahead! Come relax in our hotel's one and only outdoor greenery space.", "choices": []}
]

@onready var text_suitcase = [
	{"text": "A suitcase, brazened with a big letter 'M'. Open it?", "choices": [
		{"text": "Yes", "next_line": 1}]
	},
	
	{"text": "(You rummage through the suitcase, finding ordinary items like clothes and toiletries. However, you find three items of interest)", "choices": []},
	{"text": "(You take the items)", "choices": []},
]
@onready var text_suitcase_default = [
	{"text": "M's suitcase. It's filled with items both ordinary and luxurious.", "choices": []},
]

@onready var text_phone_q1 = [
	{"text": "... *BEEP* *BEEP* *BEEP* *BEEP*...", "choices": []},
	{"text": "The phone doesn't seem to be working.", "choices": []}
]

@onready var text_phone_q4 = [
	{"text": "... *BEEP* *BEEP* *BEEP* *BEEP*...", "choices": []},
	{"text": "The phone doesn't seem to be working.", "choices": []},
	{"text": "(I should talk to the Concierge to find a working phone.)", "choices": []}
]

@onready var text_phone_room4 = [
	{"text": "Enter the number on the business card?", "choices": [
		{"text": "Yes", "next_line": 1}
	]},
	
	{"text": "*RING* *RING*... *RING* *RING*...", "choices": []},
	{"text": "*RING* *RING*... *RI-", "choices": []},
	{"text": "*CLICK* M. It's Q. Where have you been? You were supposed to call me hours ago.", "choices": []},
	{"text": "Look, I'm here in the hotel. You told me to come here, I'm here.", "choices": []},
	{"text": "I've been waiting since last night. Room 8.", "choices": []},
]

@onready var text_computer = [
	{"text": "What would you like to do?", "choices": [
		{"text": "Insert flash drive", "next_line": 1}
	]},
	
	{"text": "(You insert the flash drive)", "choices": []},
	{"text": "*BEEP* *BOOP* *BEEP*", "choices": []},
	{"text": "(The flash drive window pops up, inside which is a single file.)", "choices": []},
	{"text": "(The file is corrupted, and cannot be viewed. However, there is an option to print.)", "choices": []},
	{"text": "Print the file?", "choices": [
		{"text": "Yes", "next_line": 6}
	]},
	{"text": "*whirrrrrrrrr* ... *boop* *beep*", "choices": []},
	{"text": "What is this?", "choices": []},
]
@onready var text_computer_printed = [
	{"text": "The email account from before is still open... best not to peek.", "choices": []},
]

# RED TREE
@onready var text_red_tree = [
	{"text": "(This looks like the red tree in the photograph.)", "choices": []},
	{"text": "(You search the tree, parting the branches and pushing aside the leaves.)", "choices": []},
	{"text": "(You find a small slip of paper wedged inside.)", "choices": []},
]

# SAFE OPENED
@onready var text_safe_opened = [
	{"text": "*CLICK*", "choices": []},
	{"text": "(The safe is open!)", "choices": []},
	{"text": "(You look inside, and see a hardbound book and a small, silver key.)", "choices": []},
	{"text": "\n[Item received: M's Journal]\n[Item received: Wine cellar key]", "choices": []},
	{"text": "Read the journal?", "choices": [
		{"text": "Yes", "next_line": 5}
	]},
	{"text": "(You open the journal.)", "choices": []},
]

@onready var text_m_journal = [
	{"text": "April 7th 20XX.", "choices": []},
	{"text": "I just arrived at the hotel. I wish I had time to rest, but there's so much to do.", "choices": []},
	{"text": "An old associate of mine resurfaced a few days ago, demanding that I repay him for services previously rendered. I was hoping he would forget.", "choices": []},
	{"text": "Luckily, he asked for something I have in abundance - an expensive bottle of wine. Unluckily, I do not have the specific type he demands.", "choices": []},
	{"text": "However, I do have a workaround. The Pétrus Noir has an almost pitch-black color to the wine. I have a bottle just like it in the hotel's wine cellar.", "choices": []},
	{"text": "I was also able to acquire an exact copy of the Pétrus Noir wine label, stored on my flash drive.", "choices": []},
	{"text": "If I can switch the labels, my associate will have his wine, I'll be free from my debt, and none will be the wiser.", "choices": []},
	{"text": "However... it doesn't help that I've been having blackouts again... lapses in memory...", "choices": []},
	{"text": "I only hope this doesn't impair my ability to finish this.", "choices": []},
	{"text": "I'll have to leave some notes to myself around the hotel... in case I'm not able to remember what needs to be done.", "choices": []},
	{"text": "But I'll have to be secretive... no one can ever find out about this.", "choices": []},
	{"text": "...", "choices": []},
	{"text": "Life has been a whirlwind. I only hope things calm down soon.", "choices": []},
	{"text": "-M", "choices": []},
]

# Reference to player to freeze movement
@onready var player = %Player

# UI for choice buttons
#@onready var choiceContainer = $Panel/ChoiceContainer
@onready var choiceButtonScene = preload("res://dialogue_option_button.tscn") # small Button scene

func _ready():
	if GameState.get_flag("hasSpokenMonologue") == false:
		start_dialogue(player, text_monologue, player)
	
	if %OldLady and %OldLady.has_node("WalkOut"):
		oldLadyWalkOut = %OldLady.get_node("WalkOut")
	else:
		oldLadyWalkOut = null

# ---------------- Dialogue System ----------------
func start_dialogue(npc_node: Node2D, lines: Array, player_ref):
	if !isTalking: 
		isTalking = true
		dialogueLines = lines
		currentLine = 0
		isActive = true
		visible = true
		player = player_ref
		
#		get npc name from names dictionary - if doesn't 		exist, use default npc_node.name
		npcName = interactableNames.get(npc_node.name, npc_node.name)

		if player:
			player.canMove = false

		# Move dialogue panel near NPC
		var panel_size = $Panel.get_size()
		$Panel.position = Vector2(
			npc_node.global_position.x - panel_size.x / 2,
			npc_node.global_position.y - panel_size.y / 2 - 8
		)

		_show_line()

func _show_line():
	# Clear previous dialogue choice options
	#for child in choiceContainer.get_children():
		#child.queue_free()

	if currentLine >= dialogueLines.size():
		_end_dialogue()
		return

	var line_data = dialogueLines[currentLine]

	# CHANGED: Store full text and start typing effect
	full_text = npcName + ": " + line_data.text
	current_char_index = 0
	is_typing = true
	typing_timer = 0.0
	$Panel/Label.text = ""  # Start with empty text

	# Show choices if any (but don't allow interaction until typing is done)
	if line_data.has("choices") and line_data.choices.size() > 0:
		isActive = false  # block linear advancement while choices exist
		for choice in line_data.choices:
			var btn = choiceButtonScene.instantiate()
			btn.text = choice.text
			btn.pressed.connect(func(): _on_choice_selected(choice, btn))
			btn.disabled = true  # CHANGED: Disable buttons during typing
			btn.visible = false
			$Panel.add_child(btn)
			
			# Bottom-right alignment
			btn.anchor_left = 1
			btn.anchor_top = 1
			btn.anchor_right = 1
			btn.anchor_bottom = 1

			btn.offset_right = -10   # 10px from right
			btn.offset_bottom = -70  # 10px from bottom
			btn.offset_left = -btn.size.x
			btn.offset_top = -btn.size.y
	else:
		isActive = false  # CHANGED: Don't allow advancement until typing is done
		
func _handle_typing(delta):
	if not is_typing:
		return
		
	typing_timer += delta
	
	if typing_timer >= typing_speed:
		typing_timer = 0.0
		current_char_index += 1
		
		# Update the displayed text
		$Panel/Label.text = full_text.substr(0, current_char_index)
		
		# Check if we've displayed all characters
		if current_char_index >= full_text.length():
			is_typing = false
			_on_typing_finished()

# NEW FUNCTION - Called when typing animation finishes
func _on_typing_finished():
	# Re-enable choice buttons if they exist
	for child in $Panel.get_children():
		if child is Button:
			child.disabled = false
			child.visible = true
	
	# Allow advancement if no choices
	var line_data = dialogueLines[currentLine]
	if not (line_data.has("choices") and line_data.choices.size() > 0):
		isActive = true


func _on_choice_selected(choice: Dictionary, btn: Button):
	if btn:
		btn.queue_free()  # removes the button from the scene
		
	if choice.has("next_line"):
		currentLine = choice.next_line
	else:
#		never reached
		currentLine += 1
	_show_line()

func _process(delta):
	# Handle typing animation
	_handle_typing(delta)
	
	# Allow skipping typing by pressing interact
	if is_typing and Input.is_action_just_pressed("interact"):
		# Skip to end of typing
		current_char_index = full_text.length()
		$Panel/Label.text = full_text
		is_typing = false
		_on_typing_finished()
		return
	
	# Original advancement logic (only when not typing)
	if isActive and not is_typing and Input.is_action_just_pressed("interact"):
		currentLine += 1
		_show_line()
		
#	DEBUG
	#if Input.is_action_just_pressed("debug_addItems"):
		#Inventory.add_item(flash_drive)
		#Inventory.add_item(business_card)
		#Inventory.add_item(picture)
		#Inventory.add_item(glasses)

func _end_dialogue():
	visible = false
	isActive = false
	isTalking = false
	currentLine = 0
	if player:
		player.canMove = true
	get_parent().call_deferred("_on_dialogue_ended")
	emit_signal("dialogue_finished")
	
	match npcName:
		"Player":
			GameState.set_flag("hasSpokenMonologue", true)
			%BlackScreen.queue_free()
		"Concierge":
			if GameState.quest == 1:
				Inventory.add_item(room_key)
		"Suitcase":
			if GameState.quest == 3:
				Inventory.add_item(flash_drive)
				Inventory.add_item(business_card)
				Inventory.add_item(picture)
				GameState.advance_quest()
		"Old Lady":
			if GameState.quest == 4 && GameState.get_flag("GaveGlasses") == true:
				if oldLadyWalkOut.walking == false: oldLadyWalkOut.walk_out()
				if player:
					player.canMove = false
		"Computer 3":
			if GameState.quest == 4 && GameState.get_flag("hasPrintedLabel") == false:
				Inventory.add_item(label)
				GameState.set_flag("hasPrintedLabel", 1)
				
#				if you have the journal, you opened the 				safe, so advance to quest 5
				if Inventory.has_item("m_journal"):
					GameState.advance_quest()
		"M's Associate":
			if GameState.quest == 4:
				Inventory.add_item(paper_clue_1)
		"Tree":
			if GameState.quest == 4:
				Inventory.add_item(paper_clue_2)
		"[Cellar Door]":
			if GameState.quest == 5:
				GameState.advance_quest()
		"Player [with wine]":
			if GameState.quest == 6:
				GameState.advance_quest()
				Inventory.add_item(wine_petrus_noir)
				if Inventory.has_item("label"):
					Inventory.remove_item("label")
		"GangLeader":
			if GameState.quest == 7:
				GameState.advance_quest()
		"Safe":
			Inventory.add_item(m_journal)
			Inventory.add_item(wine_cellar_key)
			GameState.set_flag("hasCellarKey", 1)
			
#				if you also printed the label from the 				flash drive, advance to quest 5
			if GameState.get_flag("hasPrintedLabel") == true:
				GameState.advance_quest()
				
			start_dialogue(node_journal, text_m_journal, player)
		"Bed":
	#		show the end black screen
			%EndScreenPanel.visible = true
			%Player.canMove = false

# ---------------- NPC Interactions ----------------
func _on_concierge_interact(npc_node):
	var lines_to_show: Array
	match GameState.quest:
		0:
			lines_to_show = text_concierge_q0
			GameState.advance_quest()
		1:
			lines_to_show = text_concierge_q1
		2:
			lines_to_show = text_concierge_q2
			GameState.advance_quest()
		3:
			lines_to_show = text_concierge_q3
		4:
#			have you tried the phone in your room?
#				NO
			if GameState.get_flag("hasTriedPhone") == false:
				lines_to_show = text_concierge_default
			else:
#				YES
				if GameState.get_flag("hasAskedConciergePhone") == false:
#					Have you talked to concierge about phone?
					lines_to_show = text_concierge_q4_phone
					GameState.set_flag("hasAskedConciergePhone", 1)
				else:
					lines_to_show = text_concierge_q4_phoneAsked
		5:
			if GameState.get_flag("hasApprovedCellarAccess") == false:
				lines_to_show = text_concierge_q5
				GameState.set_flag("hasApprovedCellarAccess", 1)
			else:
				lines_to_show = text_concierge_q5_cellarUnlocked
		_:
			lines_to_show = text_concierge_default
	start_dialogue(npc_node, lines_to_show, player)

func _on_greeter_interact(npc_node):
	start_dialogue(npc_node, text_greeter, player)

# Left Bellhop
func _on_bellhop_interact(npc_node):
	match GameState.quest:
		0:
			start_dialogue(npc_node, text_bellhop_1, player)
		1:
			start_dialogue(npc_node, text_bellhopL_2, player)
		_:
			start_dialogue(npc_node, text_bellhop_default, player)

# Right bellhop
func _on_bellhop_2_interact(npc_node: Variant) -> void:
	match GameState.quest:
		0:
			start_dialogue(npc_node, text_bellhop_1, player)
		1:
			start_dialogue(npc_node, text_bellhopR_2, player)
		_:
			start_dialogue(npc_node, text_bellhop_default, player)

func _on_sign_main_right_interact(npc_node):
	match GameState.quest:
		_:
			start_dialogue(npc_node, text_sign_mainRight, player)


func _on_suitcase_interact(npc_node: Variant) -> void:
	match GameState.quest:
		3:
			start_dialogue(npc_node, text_suitcase, player)
		_:
			start_dialogue(npc_node, text_suitcase_default, player)


func _on_sign_main_left_interact(npc_node):
	match GameState.quest:
		_:
			start_dialogue(npc_node, text_sign_mainLeft, player)


func _on_computer_printer_table_interact(npc_node):
	match GameState.quest:
		4:
			if GameState.get_flag("hasPrintedLabel") == false:
				start_dialogue(npc_node, text_computer, player)
			else:
				start_dialogue(npc_node, text_computer_printed, player)
		_:
			start_dialogue(npc_node, text_computer_printed, player)

func _on_old_lady_interact(npc_node):
	if !oldLadyWalkOut.walking:
		match GameState.quest:
			4:
				if Inventory.has_item("glasses"):
					Inventory.remove_item("glasses")
					GameState.set_flag("GaveGlasses", 1)
					start_dialogue(npc_node, text_old_lady_q4_gotGlasses, player)
				else:
					start_dialogue(npc_node, text_old_lady_q4, player)
			_:
				start_dialogue(npc_node, text_old_lady_q1, player)


func _on_glasses_interact(npc_node):
	match GameState.quest:
		4:
			Inventory.add_item(glasses)
			%Glasses.queue_free()


func _on_phone_interact(npc_node):
	match GameState.quest:
		4:
			print("tried phone q4")
			GameState.set_flag("hasTriedPhone", 1)
			start_dialogue(npc_node, text_phone_q4, player)
		_:
			print("tried phone default")
			GameState.set_flag("hasTriedPhone", 1)
			start_dialogue(npc_node, text_phone_q1, player)


func _on_phone_room_4_interact(npc_node):
	match GameState.quest:
		4:
			if GameState.get_flag("hasCalledAssociate") == false:
				start_dialogue(npc_node, text_phone_room4, player)
				GameState.set_flag("hasCalledAssociate", 1)
			else:
				start_dialogue(npc_node, text_phone_q1, player)
		_:
			start_dialogue(npc_node, text_phone_q1, player)


func _on_associate_interact(npc_node):
	match GameState.quest:
		4:
			if GameState.get_flag("hasMetAssociate") == false:
				start_dialogue(npc_node, text_associate_q4_1, player)
				GameState.set_flag("hasMetAssociate", 1)
			else:
				start_dialogue(npc_node, text_associate_q4_2, player)
		_:
			start_dialogue(npc_node, text_associate_q4_2, player)


func _on_player_blocker_room_8_interact(npc_node):
	start_dialogue(npc_node, text_associate_playerBlocker, player)


func _on_sign_main_up_interact(npc_node):
	start_dialogue(npc_node, text_sign_mainUp, player)


func _on_red_tree_interact(npc_node):
	match GameState.quest:
		4:
			if GameState.get_flag("GotPaperClue2") == false:
				start_dialogue(npc_node, text_red_tree, player)
				GameState.set_flag("GotPaperClue2", 1)
			else:
				pass


func _on_safe_safe_opened(npc_node):
	start_dialogue(npc_node, text_safe_opened, player)

# WINE CELLAR DOOR
@onready var text_wineCellar_q1 = [
	{"text": "This door is locked.", "choices": []},
]
@onready var text_wineCellar_q2 = [
	{"text": "This door is locked.", "choices": []},
	{"text": "Maybe the Concierge can give me access.", "choices": []},
]
@onready var text_wineCellar_q4_hasKey = [
	{"text": "I have the key, but I should investigate M's items before going in.", "choices": []},
]
@onready var text_wineCellar_q5 = [
	{"text": "Use the wine cellar key?", "choices": [
		{"text": "Yes", "next_line": 1}
	]},
	
	{"text": "You insert the key into the door and turn. The door opens.", "choices": []},
]

func _on_wine_cellar_door_interact(npc_node):
	match GameState.quest:
		5:
			start_dialogue(npc_node, text_wineCellar_q5, player)
		4:
			if GameState.get_flag("hasCellarKey") == true:
				start_dialogue(npc_node, text_wineCellar_q4_hasKey, player)
		2:
			start_dialogue(npc_node, text_wineCellar_q2, player)
		1:
			start_dialogue(npc_node, text_wineCellar_q1, player)
		_:
			pass

# ------ ITEMS -------
@onready var text_winePetrusNoir = [
	{"text": "You pick up the wine. It has a dark, rich color similar to the Pétrus Noir.", "choices": []},
	{"text": "Swap the labels?", "choices": [
		{"text": "Yes", "next_line": 2}
	]},
	
	{"text": "You peel off the label from the wine bottle, then stick on the printed label.", "choices": []},
]

func _on_wine_petrus_noir_interact(npc_node):
	match GameState.quest:
		6:
			if winePetrusNoir: winePetrusNoir.queue_free()
			start_dialogue(npc_node, text_winePetrusNoir, player)


func _on_gang_leader_interact(npc_node):
	match GameState.quest:
		8:
			start_dialogue(npc_node, text_gangLeader_q8, player)
		7:
			start_dialogue(npc_node, text_gangLeader_q7, player)
			GameState.advance_quest()
		_:
			start_dialogue(npc_node, text_gangLeader_q2, player)


func _on_old_lady_tree_exited() -> void:
	print("old lady - exited tree")
	player.canMove = true

# broken computer table
@onready var text_computerTableBroken_1 = [
	{"text": "The computer isn't turning on. You try holding the power button...", "choices": []},
	{"text": "Nothing.", "choices": []}
]
@onready var text_computerTableBroken_2 = [
	{"text": "This computer is on, but it seems to have a virus. There are pop-up windows everywhere.", "choices": []},
	{"text": "It's unusable.", "choices": []}
]

func _on_computer_table_broken_interact(npc_node):
	start_dialogue(npc_node, text_computerTableBroken_1, player)


func _on_computer_table_broken_2_interact(npc_node):
	start_dialogue(npc_node, text_computerTableBroken_2, player)

# broken computer table
@onready var text_courtyard_person = [
	{"text": "This is the courtyard? Who are they kidding with this? It's not even outdoors.", "choices": []},
	{"text": "Damn, this hotel is cheap.", "choices": []}
]

func _on_courtyard_person_interact(npc_node):
	start_dialogue(npc_node, text_courtyard_person, player)

# mom, dad, and kids
@onready var text_room2_dad = [
	{"text": "I can't wait to eat breakfast. Free, unlimited breakfasts are the best part of hotels.", "choices": []},
	{"text": "Wait... does this place even have breakfast?", "choices": []},
	{"text": "It better for how much I'm paying.", "choices": []},
]
@onready var text_room2_mom = [
	{"text": "... 8... 9... 10 (exhales) *whooooooo*.", "choices": []},
	{"text": "I'm taking a break over here. My kid is driving me absolutely insane.", "choices": []}
]
@onready var text_room2_kid = [
	{"text": "Mommy and daddy told me to stop bouncing on the bed. They said it was really annoying.", "choices": []},
	{"text": "What else are you supposed to do on a bed though other than bouncing and sleeping?", "choices": []}
]

func _on_room_2_dad_interact(npc_node: Variant) -> void:
	start_dialogue(npc_node, text_room2_dad, player)


func _on_room_2_mom_interact(npc_node: Variant) -> void:
	start_dialogue(npc_node, text_room2_mom, player)


func _on_room_2_kid_interact(npc_node: Variant) -> void:
	start_dialogue(npc_node, text_room2_kid, player)

@onready var text_player_bed = [
	{"text": "It's been a long day... time to get some rest.", "choices": []},
	{"text": "Go to sleep?", "choices": [
		{"text": "Yes", "next_line": 2}
	]},
	
	{"text": "(You settle in bed and drift off to sleep.)", "choices": []},
]
@onready var text_player_bed_q1 = [
	{"text": "A nice, comfy bed.", "choices": []},
]

func _on_player_bed_interact(npc_node):
	match GameState.quest:
		8:
			start_dialogue(npc_node, text_player_bed, player)
		_:
			start_dialogue(npc_node, text_player_bed_q1, player)

@onready var text_painting_admirer = [
	{"text": "Hmmm... what a curious painting. It evokes such fear in the viewer.", "choices": []},
	{"text": "I wonder what was going through the artist's mind while drawing this.", "choices": []}
]

func _on_painting_admirer_interact(npc_node: Variant) -> void:
	start_dialogue(npc_node, text_painting_admirer, player)

@onready var text_bathroom_guy = [
	{"text": "Woah! Give a guy some privacy, will ya?", "choices": []},
	{"text": "Geez... can't even take a nice bath in peace these days.", "choices": []}
]

func _on_bathroom_guy_interact(npc_node: Variant) -> void:
	start_dialogue(npc_node, text_bathroom_guy, player)
