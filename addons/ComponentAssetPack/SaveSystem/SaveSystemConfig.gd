@icon("file_terminal.svg")
extends Node
class_name ConfigSaveSystem

## The path that we will save the file, usually is user://name_of_file. [b]DO NOT[/b] use the include the file extension.
@export_placeholder("example: user://settings") var path: String

## The type of the config file. [br]
## [b].cfg[/b]: Config File. [url=https://en.wikipedia.org/wiki/Configuration_file]More Information[/url] [br]
## [b].ini[/b]: INI file. [url=https://en.wikipedia.org/wiki/INI_file]More Information[/url]
@export_enum(".cfg",".ini") var file_type:String = ".cfg"

## If [b]true[/b], the game will load the saved file on start,
@export var auto_load_on_ready: bool = true

# Holds the data in memory so we don't have to read the disk every time!
var _sv_file: ConfigFile = ConfigFile.new()

var full_path:String = ""

func _ready() -> void:
	if path.is_empty():
		push_error("You have no path added to save.")
		return
	
	full_path = path + file_type
	
	if auto_load_on_ready:
		load_from_disk()

## Sets a value in memory. DOES NOT save to disk yet (better for performance).
func set_data(section: String, key: String, value: Variant) -> void:
	_sv_file.set_value(section, key, value)

## Gets a value from memory. Includes a failsafe default.
func get_data(section: String, key: String, default: Variant = null) -> Variant:
	return _sv_file.get_value(section, key, default)

## Returns if a section exists in the file.
func has_section(section: String) -> bool:
	return _sv_file.has_section(section)

## Returns if a key exists in the file.
func has_section_key(section: String, key: String) -> bool:
	return _sv_file.has_section_key(section, key)

## Removes a section from the file. Includes a safe check.
func erase_section(section: String) -> void:
	if has_section(section):
		_sv_file.erase_section(section)
	else:
		push_error("ConfigSaveSystem: You tried to erase %s section, but there is no section named that way." % section)

## Removes a key from a section of the file. Includes a safe check.
func erase_section_key(section: String, key: String) -> void:
	if has_section_key(section, key):
		_sv_file.erase_section_key(section, key)
	else:
		push_error("ConfigSaveSystem: You tried to erase %s key, but there is no key in the %s section named that way." % [key, section])

## Call this to actually write all the set_data changes to the hard drive.[br]
## If Failed to save there will be an error on your output and will return [b]false[/b] else [b]true[/b]
func commit_save() -> bool:
	var err = _sv_file.save(full_path)
	if err != OK:
		push_error("ConfigSaveSystem: Failed to save file at %s. Error code: %s" % [full_path, err])
		return false
	
	return true

## Reloads the file from the hard drive, overwriting current memory.
func load_from_disk() -> void:
	var err = _sv_file.load(full_path)
	# It is normal for the file to not exist the very first time the game runs.
	if err != OK and err != ERR_FILE_NOT_FOUND:
		push_error("ConfigSaveSystem: Failed to load file at %s. Error code: %s" % [full_path, err])

## Returns an array of all sections currently in the file.
func get_all_sections() -> PackedStringArray:
	return _sv_file.get_sections()

## Returns an array of all keys inside a specific section.
func get_section_keys(section: String) -> PackedStringArray:
	if has_section(section):
		return _sv_file.get_section_keys(section)
	return PackedStringArray()

## Wipes all data from memory (Call commit_save() afterward to wipe the disk).
func clear_all_data() -> void:
	_sv_file.clear()
