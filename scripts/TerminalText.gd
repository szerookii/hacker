extends RichTextLabel

const HELP_COMMAND = "help"		# Display all help commands
const DIR_COMMAND = "dir"		# Display all files and folders in current working directory
const CHANGE_DIRECTORY_COMMAND = "cd"	# Change working directory
const QUIT_COMMAND = "exit"		# Quit application
const CLEAR_COMMAND = "clear"		# Clear terminal windows

var MACHINE_IP = IP.get_local_addresses()[1]
var current_context : Context
var past_commands = []

class Context:
	var user_name = "root"
	var device_name = "EIC"
	var working_directory : Folder
	var root_directory : Folder
	var date = "27/04/2007"
	
class Folder:
	var folder_path : String
	var parent_directory : Folder
	var child_directories = []
	var child_files = []
	
	func _init(path, parent):
		folder_path = path
		parent_directory = parent
		pass
	
	func _to_string():
		return folder_path
		
class Document:
	var document_name : String
	var parent_directory : Folder
	var content : String
	var size_kb = 10
	
	func _init(name, parent):
		document_name = name
		parent_directory = parent
		pass
	
	func set_content(new_content : String):
		content = new_content
		size_kb = stepify((float(content.length()) * 8) / 1024, 0.01)
	
	func _to_string():
		return document_name
	

func _ready():
	# Initalise context, folders & files
	current_context = Context.new()
	
	if OS.has_feature("JavaScript"):
		MACHINE_IP = "127.0.0.1"
		JavaScript.eval("console.log('Playing on web')")
	
	# Root folders
	current_context.root_directory = Folder.new("", null)
	current_context.root_directory.child_directories = [
		Folder.new("Bureau", current_context.root_directory),
		Folder.new("Documents", current_context.root_directory),
		Folder.new("Téléchargement", current_context.root_directory),
		Folder.new("Musique", current_context.root_directory)
	]
	
	# Root files
	current_context.root_directory.child_files = [
		Document.new("ALire.txt", current_context.root_directory), 
		Document.new("Rapport22fév.txt", current_context.root_directory)
	]
	current_context.root_directory.child_files[0].set_content("Bienvenue dans les système informatique de l'EIC. Tapez '%s' pour afficher la liste des commandes." % HELP_COMMAND)
	current_context.root_directory.child_files[1].set_content("Par Mathis L., le 22 février 2007\n\nRapport de mise à jour de sécurité #1\n\nMISE A JOUR :\n-	Serveur mis à jour\n-	Installation de paint\n-	Installation Bureau à Distance\n-	Mise à niveau du pare-feu\n-	Suppression des règles pare-feu visant la non utilisation de Google sur les serveurs russes\n\nNotes :\n-	Les IPs des serveurs estoniens visant à être utilisés pour une futur attaque ont été stocké dans les serveurs russes.")
	
	# Bureau/
	current_context.root_directory.child_directories[0].child_directories = [
		Folder.new("NSFW", current_context.root_directory.child_directories[0]),
		Folder.new("IDA_Pro_7.6", current_context.root_directory.child_directories[0])
	]
	current_context.root_directory.child_directories[0].child_files = [
		Document.new("IPs.txt", current_context.root_directory.child_directories[0]),
		Document.new("Observation_oiseaux.txt", current_context.root_directory.child_directories[0])
	]
	current_context.root_directory.child_directories[0].child_files[0].set_content("Pour lancer un DDoS utilisez cette commande : 'ddos <ip>'\nIP serveurs estoniens : %s" % MACHINE_IP)
	
	# Bureau/NSFW
	current_context.root_directory.child_directories[0].child_directories[0].child_files = [
		Document.new("Sextape Jean Dujardin.mp4", current_context.root_directory.child_directories[0].child_directories[0])
	]
	current_context.root_directory.child_directories[0].child_directories[0].child_files[0].set_content("On aurait bien rigolé mais non.")
	
	# Documents
	current_context.root_directory.child_directories[1].child_files = [
		Document.new("Fiche_De_Paye_2007.xls", current_context.root_directory.child_directories[1]),
		Document.new("Employés_A_Revoyer.xls", current_context.root_directory.child_directories[1]),
		Document.new("Historique_De_Navigation.txt", current_context.root_directory.child_directories[1]),
	]
	current_context.root_directory.child_directories[1].child_files[0].set_content("Pas d'argent ne sera donné cette année, vive le communisme !")
	current_context.root_directory.child_directories[1].child_files[1].set_content("Aucuns employé sera renvoyé pour le moment.")
	current_context.root_directory.child_directories[1].child_files[2].set_content("-- Historique récent --\n\n- YouTube\n- Pornhub\n- Blagues drôles pour draguer\n- Pornhub.com/gay\n- Code cadeau mystère pokémon 2007")
	
	# Téléchargement/
	current_context.root_directory.child_directories[2].child_files = [
		Document.new("CrackOffice.rar", current_context.root_directory.child_directories[2]),
		Document.new("Comment_DDoS_Un_Serveur_TUTO_2007.pdf", current_context.root_directory.child_directories[2])
	]
	current_context.root_directory.child_directories[2].child_files[0].set_content("Pas de crack ici lol, c'est pas bien de hack les trucs délinquant.")
	
	# Musique/
	current_context.root_directory.child_directories[3].child_files = [
		Document.new("Coco_-_Wejdene.mp3", current_context.root_directory.child_directories[3]),
		Document.new("Faded_Love_-_szeroki.mp3", current_context.root_directory.child_directories[3]),
		Document.new("Guapman_-_menace_Santana.mp3", current_context.root_directory.child_directories[3])
	]
	
	current_context.working_directory = current_context.root_directory
	
	clear()
	
	# Draw header
	draw_new_line("EIC Server v1.0.3-ALPHA3", false, false, false)
	draw_new_line("Copyright (C) szeroki", false, true, false)
	draw_new_line("Date %s" % current_context.date, false, true, false)
	
	newline()
	
	# Display help prompt
	draw_new_line("Pour afficher l'aide, tapez \'%s'." % HELP_COMMAND, false, true, true)
	draw_new_line("", false, true, false)
	
	# Draw new line with current working directory
	draw_new_line("", true, false, false)
	
	pass
	
func draw_new_line(input : String, draw_prefix : bool, new_line_before : bool, new_line_after : bool):
	if (new_line_before):
		newline()
	
	if (draw_prefix):
		text += current_context.user_name.to_lower() + "@" + current_context.device_name.to_lower()
		
		if (current_context.working_directory.folder_path != ""):
			text += "<" + current_context.working_directory.folder_path + ">"
		else:
			#text += "<*>"
			pass
		text += " # "
	
	text += input
	
	if (new_line_after):
		newline()
	
	pass

func draw_new_character(input):
	text += input
	pass

var current_user_input = ""

const ALPHANUMERIC_KEYS := {
	KEY_SPACE:" ", KEY_APOSTROPHE:"'", KEY_COMMA:",", KEY_MINUS:"-", KEY_PERIOD:".", KEY_SLASH:"/",
	KEY_0:"0", KEY_1:"1", KEY_2:"2", KEY_3:"3", KEY_4:"4", KEY_5:"5", KEY_6:"6", KEY_7:"7", KEY_8:"8", KEY_9:"9",
	KEY_SEMICOLON:";", KEY_EQUAL:"=", KEY_QUOTEDBL:"`", KEY_QUOTELEFT:"`",

	KEY_A:"a", KEY_B:"b", KEY_C:"c", KEY_D:"d", KEY_E:"e", KEY_F:"f", KEY_G:"g", KEY_H:"h", KEY_I:"i",
	KEY_J:"j", KEY_K:"k", KEY_L:"l", KEY_M:"m", KEY_N:"n", KEY_O:"o", KEY_P:"p", KEY_Q:"q", KEY_R:"r",
	KEY_S:"s", KEY_T:"t", KEY_U:"u", KEY_V:"v", KEY_W:"w", KEY_X:"x", KEY_Y:"y", KEY_Z:"z"
}

var current_past_command = 0

func _input(event):	
	if event is InputEventKey and event.pressed:
		# Cancel input
		if event.control and event.scancode == KEY_C:
			current_user_input = ""
			draw_new_line("^C", false, false, false)
			
			current_past_command = past_commands.size() - 1
			
			# Display current context
			draw_new_line("", true, true, false)
			return
		
		# Detect alphanumeric input
		if event.scancode in ALPHANUMERIC_KEYS and !event.control:
			var character = char(event.unicode)
			if (character == " " && current_user_input.length() == 0):
				return
				
			current_user_input += character
			draw_new_character(character)
			# print(character)
			return
		
		# Backspace, delete last typed character
		if event.scancode == KEY_BACKSPACE:
			# Backspace, delete character behind caret
			if (current_user_input.length() > 0):
				current_user_input.erase(current_user_input.length()-1, 1)
				text = text.left(text.length()-1)
			
			return
		
		# Cycle up through past commands
		if event.scancode == KEY_UP:
			if (past_commands.size() > 0):
				if (current_past_command > 0):
					current_past_command -= 1
				else:
					#current_past_command = past_commands.size() - 1
					pass
					
				if (current_user_input.length() > 0):
					text = text.left(text.length()-current_user_input.length())
					
				current_user_input = past_commands[current_past_command]
				text += current_user_input
			
				print(current_past_command)
				return
		
		
		# Cycle down through past commands
		if event.scancode == KEY_DOWN:
			if (past_commands.size() > 0):
				if (current_past_command < (past_commands.size() - 1)):
					current_past_command += 1
				else:
					# current_past_command = 0
					pass
					
				if (current_user_input.length() > 0):
					text = text.left(text.length()-current_user_input.length())
				current_user_input = past_commands[current_past_command]
				text += current_user_input
				
				print(current_past_command)
				return
		
		# Detect 'enter' command
		if event.scancode == KEY_ENTER:
			# Submit user input, parse and clear current_user_input variable
			
			# Don't attempt to parse if input is blank
			if (current_user_input.length() > 0):
				if (!past_commands.has(current_user_input)):
					past_commands.append(current_user_input)
				current_past_command = past_commands.size() - 1
				
				if (!parse_input(current_user_input)):
					draw_new_line("Commande introuvable. Tapez '%s' pour afficher la liste des commandes." % HELP_COMMAND, false, true, false)
					
					# Display current context
					draw_new_line("", true, true,false)
					
				current_user_input = ""
			
			return
		
		# Detect TAB auto-complete
		if event.scancode == KEY_TAB:
			# Don't attempt to auto-complete if input is blank
			if (current_user_input.length() > 0):
				
				var split_input = current_user_input.split(" ", false)
				
				if (split_input.size() > 0):
					if (split_input.size() == 1):
						var hint_text = split_input[0]
				
						# Search folders
						var folder_search_results = []
						
						if (current_context.working_directory.child_directories.size() > 0):
							for folder in current_context.working_directory.child_directories:
								if (folder.to_string().to_lower().begins_with(hint_text.to_lower())):
									folder_search_results.append(folder)
						
						if (folder_search_results.size() > 0):
							text = text.left(text.length()-current_user_input.length())
							current_user_input = str(folder_search_results[0].to_string())
							text += current_user_input
						
						# Search documents
						var document_search_results = []
						
						if (current_context.working_directory.child_files.size() > 0):
							for document in current_context.working_directory.child_files:
								if (document.to_string().to_lower().begins_with(hint_text.to_lower())):
									document_search_results.append(document)
						
						if (document_search_results.size() > 0):
							text = text.left(text.length()-current_user_input.length())
							current_user_input = str(document_search_results[0].to_string())
							text += current_user_input
					elif (split_input.size() == 2):
						var cmd = split_input[0]
						var hint_text = split_input[1]
				
						# Search folders
						var folder_search_results = []
						
						if (current_context.working_directory.child_directories.size() > 0):
							for folder in current_context.working_directory.child_directories:
								if (folder.to_string().to_lower().begins_with(hint_text.to_lower())):
									folder_search_results.append(folder)
						
						if (folder_search_results.size() > 0):
							text = text.left(text.length()-current_user_input.length())
							current_user_input = cmd + " " + str(folder_search_results[0].to_string())
							text +=  current_user_input
						
						# Search documents
						var document_search_results = []
						
						if (current_context.working_directory.child_files.size() > 0):
							for document in current_context.working_directory.child_files:
								if (document.to_string().to_lower().begins_with(hint_text.to_lower())):
									document_search_results.append(document)
						
						if (document_search_results.size() > 0):
							text = text.left(text.length()-current_user_input.length())
							current_user_input = cmd + " " + str(document_search_results[0].to_string())
							text += current_user_input
			

const SWEAR_WORDS = [
	"ass",
	"fuck",
	"shit",
	"cunt"
]

func parse_input(input : String):
	var split_input = input.split(" ", false)
	
	if (split_input.size() > 0):
		match (split_input[0].to_lower()):
			CHANGE_DIRECTORY_COMMAND:
				if (split_input.size() == 1):
					# not enough arguments supplied
					draw_new_line("Pas de chemin spécifié.", false, true, true)
					pass
				
				else:
					if (split_input[1] == ".."):
						# Go up a level
						if (current_context.working_directory.parent_directory != null):
							current_context.working_directory = current_context.working_directory.parent_directory
							
						# Display current context
						draw_new_line("", true, true, false)
						return true
					
					if (current_context.working_directory.child_directories.size() > 0):
						var search_successful = false
						for folder in current_context.working_directory.child_directories:
							if (split_input[1].to_lower() == folder.to_string().to_lower()):
								# Go to sub-folder
								current_context.working_directory = folder
								search_successful = true
								
								# Display current context
								draw_new_line("", true, true, false)
								return true
						
						if (!search_successful):
							draw_new_line("  Chemin introuvable.", false, true, false)
							
							# Display current context
							draw_new_line("", true, true, false)
							return true
				
				# Display current context
				draw_new_line("", true, true, false)
				return true
			HELP_COMMAND:
				display_help_commands()
				return true
			DIR_COMMAND:
				if (current_context.working_directory.child_directories.size() == 0 && current_context.working_directory.child_files.size() == 0):
					draw_new_line("Pas de sous dossier/fichier.", false, true, true)
					
					# Display current context
					draw_new_line("", true, true, false)
					return true
				
				draw_new_line(" - - - - - - - - - - - - - - - - - ", false, true, false)
				var num_files = current_context.working_directory.child_files.size() if (current_context.working_directory.child_files != null) else 0
				var num_folders = current_context.working_directory.child_directories.size() if (current_context.working_directory.child_directories != null) else 0
				draw_new_line(" [" + str(num_folders) + " dossiers, " + str(num_files) + " fichiers]", false, true, false)
				draw_new_line(" - - - - - - - - - - - - - - - - - ", false, true, false)
				
				for folder in current_context.working_directory.child_directories:
					draw_new_line("  <DIR> " + folder.to_string(), false, true, false)
					num_files = folder.child_files.size() if (folder.child_files != null) else 0
					num_folders = folder.child_directories.size() if (folder.child_directories != null) else 0
					draw_new_line(" [" + str(num_files) + " fichiers, " + str(num_folders) + " dossiers] ", false, false, false)
				
				if (current_context.working_directory.child_directories.size() > 0 && current_context.working_directory.child_files.size() > 0):
					newline()
				
				for file in  current_context.working_directory.child_files:
					draw_new_line("  " + file.to_string(), false, true, false)	
				
				newline()
				# Display current context
				draw_new_line("", true, true, false)
				return true
			CLEAR_COMMAND:
				clear();
				# Display current context
				draw_new_line("", true, false, false)
				return true
			QUIT_COMMAND:
				get_tree().quit()
				return true
		
		# Search documents
		var document_search_results = []
		
		if (current_context.working_directory.child_files.size() > 0):
			for document in current_context.working_directory.child_files:
				if (document.to_string().to_lower() == split_input[0].to_lower()):
					document_search_results.append(document)
		
		if (document_search_results.size() > 0):
			draw_new_line(" - - - - - - - - - - - - - - - - - ", false, true, false)
			draw_new_line("Nom: %s" % str(document_search_results[0].document_name), false, true, false)
			if (document_search_results[0].size_kb != null):
				draw_new_line("Taille: %sKb" % str(document_search_results[0].size_kb), false, true, false)
			draw_new_line(" - - - - - - - - - - - - - - - - - ", false, true, false)
			
			draw_new_line(str(document_search_results[0].content), false, true, true)
			
			# Display current context
			draw_new_line("", true, true, false)
			return true
		
		if split_input[0] == "ddos":
			if len(split_input) > 1 && split_input[1] == MACHINE_IP:
				draw_new_line("L'attaque DDoS va être lancée...", false, true, false)
				
				yield(get_tree().create_timer(1.0), "timeout")
				
				draw_new_line("L'attaque DDoS a été lancée avec succès!", false, true, false)
				
				yield(get_tree().create_timer(1.0), "timeout")
				
				draw_new_line("Vous allez être rédiriger...", false, true, false)
				
				yield(get_tree().create_timer(1.0), "timeout")
				
				get_tree().change_scene("res://scenes/DialogueVirus.tscn")
				
				# Display current context
				draw_new_line("", true, true, false)
			
				return true
			else:
				draw_new_line("Adresse IP invalide.", false, true, false)
				
				# Display current context
				draw_new_line("", true, true, false)
				
				return true
			
	return false

func display_help_commands():
	draw_new_line("", false, true, false)
	draw_new_line("  %s       Change de dossier de travail." % CHANGE_DIRECTORY_COMMAND, false, true, false)
	draw_new_line("  %s    Efface le contenu de la console." % CLEAR_COMMAND, false, true, false)
	draw_new_line("  %s      Affiche les différents dossiers et fichiers présent dans le dossier de travail." % DIR_COMMAND, false, true, false)
	draw_new_line("  %s     Termine la session." % QUIT_COMMAND, false, true, false)
	
	newline()
	
	# Display current context
	draw_new_line("", true, true, false)
