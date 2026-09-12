@tool
@icon("chest.svg")
extends Node


# --- CONFIGURATION SWITCHES ---
@export_category("Features")
## If enabled, rolls a 0-100% check first to see if anything drops at all.
@export var use_global_drop_chance : bool = true
## If enabled, returns rolled quantities based on the Y (Min) and Z (Max) values. 
## If disabled, always returns an amount of 1.
@export var use_min_max_quantities : bool = true

@export_category("Tables")
@export var editor_drop_table: Dictionary[String, RateLine] = {}:
	set(value):
		# Cleanly disconnect old resources
		for old_res in editor_drop_table.values():
			if old_res and old_res.changed.is_connected(_on_rate_line_changed):
				old_res.changed.disconnect(_on_rate_line_changed)
		
		editor_drop_table = value
		
		# Connect new resources
		for new_res in editor_drop_table.values():
			if new_res and not new_res.changed.is_connected(_on_rate_line_changed):
				new_res.changed.connect(_on_rate_line_changed)
		update_configuration_warnings()

# --- RANDOM NUMBER GENERATION ---
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# --- INTERNAL RUNTIME CACHE ---
var _cached_items: Dictionary[String, Array] = {}
var _cached_weights: Dictionary[String, PackedFloat32Array] = {}
var _cached_totals: Dictionary[String, float] = {}
var _cached_chances: Dictionary[String, float] = {}
var _cached_quantities: Dictionary[String, Dictionary] = {} 

func _on_rate_line_changed() -> void:
	update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	for target_id in editor_drop_table.keys():
		var line_resource: RateLine = editor_drop_table[target_id]
		if not line_resource:
			warnings.append("Target ID '%s' has an empty resource slot!" % target_id)
			continue
			
		var sum : float = 0.0
		for config_vec in line_resource.drops.values():
			sum += config_vec.x
			
		if not is_equal_approx(sum, 100.0) and abs(sum - 100.0) > 0.01:
			warnings.append("Loot pool '%s' total weights equal %s%%. It must equal exactly 100%%!" % [target_id, str(sum)])
	return warnings

func _ready() -> void:
	if not Engine.is_editor_hint():
		rng.randomize()
		_build_cache()

func _build_cache() -> void:
	_cached_items.clear()
	_cached_weights.clear()
	_cached_totals.clear()
	_cached_chances.clear()
	_cached_quantities.clear()
	
	for target_id in editor_drop_table:
		var line_resource: RateLine = editor_drop_table[target_id]
		if not line_resource or line_resource.drops.is_empty():
			continue
		
		var items: Array[Variant] = [] 
		var weights := PackedFloat32Array()
		var total_weight : float = 0.0
		var quantity_map: Dictionary[Variant, Vector2i] = {}
		
		for item_id in line_resource.drops:
			var config: Vector3 = line_resource.drops[item_id]
			var weight: float = config.x
			
			if weight > 0.0:
				items.append(item_id)
				weights.append(weight)
				total_weight += weight
				quantity_map[item_id] = Vector2i(roundi(config.y), roundi(config.z))
				
		_cached_items[target_id] = items
		_cached_weights[target_id] = weights
		_cached_totals[target_id] = total_weight
		_cached_chances[target_id] = line_resource.global_drop_chance
		_cached_quantities[target_id] = quantity_map

## Rolls for loot. Supports a luck modifier and multiple rolls.
## ALWAYS returns an Array[Dictionary] formatted as [{"item": Variant, "amount": int}].
## Returns an empty Array [] if no items are dropped.
func get_drop(target_id: String, luck: float = 1.0, rolls: int = 1) -> Array[Dictionary]:
	if not _cached_totals.has(target_id):
		push_error("DropManager has no loot pool configured for ID: ", target_id)
		return []
		
	var base_weights: PackedFloat32Array = _cached_weights[target_id]
	if base_weights.is_empty():
		return []
		
	var active_weights := PackedFloat32Array()
	if luck == 1.0:
		active_weights = base_weights
	else:
		for base_weight in base_weights:
			var rarity_factor : float = ( 100.0 - base_weight ) / 100.0
			var mod_weight: float = base_weight * pow(luck, rarity_factor + 1.0)
			active_weights.append(max(mod_weight, 0.001))

	var items: Array = _cached_items[target_id]
	var target_pool_quantities: Dictionary = _cached_quantities.get(target_id, {})
	
	if use_global_drop_chance:
		var global_chance: float = _cached_chances.get(target_id, 100.0)
		var modified_chance = clampf(global_chance * luck, 0.0, 100.0)
		if rng.randf_range(0.0, 100.0) > modified_chance:
			return []

	var rolled_results: Dictionary[Variant, int] = {}

	for r in range(max(1, rolls)):
		var index: int = rng.rand_weighted(active_weights)
		if index == -1:
			continue
			
		var chosen_item: Variant = items[index]
		var quantity: int = 1
		
		if use_min_max_quantities and target_pool_quantities.has(chosen_item):
			var bounds: Vector2i = target_pool_quantities[chosen_item]
			var min_val: int = min(bounds.x, bounds.y)
			var max_val: int = max(bounds.x, bounds.y)
			if min_val > 0 or max_val > 0:
				quantity = rng.randi_range(min_val, max_val)

		rolled_results[chosen_item] = rolled_results.get(chosen_item, 0) + quantity

	var final_array: Array[Dictionary] = []
	for item_key in rolled_results:
		final_array.append({"item": item_key, "amount": rolled_results[item_key]})
		
	return final_array
