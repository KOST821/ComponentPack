# Contributing to the Component Pack

First off, thank you for considering contributing to this project! It is people like you who make the open-source community great.

To ensure this asset pack remains high-quality, organized, and optimized, please read and follow these guidelines strictly before submitting a Pull Request (PR).

## Naming & File Rules

Consistency is mandatory. Name your files exactly like this:

- **Folders, Scenes, and Code Files**: Must use **PascalCase** (e.g., ConfigSaveSystem, DropManager).

- **Node Icons**: Must use **snake_case** (e.g., file_plus.svg).

	* **Format**: `.svg` files only.

	* **Dimensions**: Must be perfectly square and a maximum size of 26x26px and minimum size of 16x16px.

	* **Color Theme**: Must strictly follow Godot's default node color system to match the parent node type.
		- `#fc7f7f` for `Node3D`
    	- `#8da5f3` for `Node2D`
		- `#8eef97` for `Control` / UI
    	- `#c38ef1` for Animation
    	- `#ffca5f` for Engine
    	- `#e0e0e0` for `Node`

- **Textures and Sprites**: Must use descriptive **snake_case** (e.g., photo_camera.png). *Do not* submit files with default or random names.

## Code Standards

- **Class Names**: Always set your `class_name` to a valid and matching name using ***PascalCase*** (e.g., `ConfigSaveSystem`, `DropManager`).

- **Naming variables**: Variables must have a clear, descriptive name (avoid using names like *a*, *b*) and must use **snake_case** (e.g., `platform_break`).

- **The underscore rule**: Variables that should not be modified by any other script should start their name with an underscore (e.g., `_tween`). That rule *does not* apply to `@export` variables.

- **Export variables**: Use `@export` variables wisely and with a description! If an `@export` variable has a range of numbers it should take, use `@export_range`. If it has a *unit of measurement*, use `@export_custom(PROPERTY_HINT_NONE, "suffix:unit of measurement")`.

```GDScript
## This is a valid description (shows in the Inspector tooltip).
@export var description_text: String

# This is NOT a valid description (only uses a single '#').
@export var bad_description_text: String

## Unconstrained value with a unit of measurement (hp).
@export_custom(PROPERTY_HINT_NONE, "suffix:hp") var base_damage: float = 5.0

## Value clamped between 0.0 and 100.0.
@export_range(0.0, 100.0) var clamped_damage: float = 5.0

## Value from 0.0 to +∞ (step of 0.1).
@export_range(0.0, 100.0, 0.1, "or_greater", "hide_control") var min_damage: float = 5.0

## Value from -∞ to 100.0 (step of 0.1).
@export_range(0.0, 100.0, 0.1, "or_less", "hide_control") var max_damage: float = 5.0

## Value with both a range (0.0 to 100.0) and a unit of measurement (hp).
@export_range(0.0, 100.0, 0.1, "suffix:hp") var ranged_damage: float = 5.0

## Combining range, infinite upper bound, and a suffix.
@export_range(0.0, 100.0, 0.1, "or_greater", "hide_control", "suffix:hp") var total_damage: float = 5.0
```

- **Use UIDs**: Always use uid for referencing files to prevent path breakage if assets are moved.

## Folder Structure

Place your files in the correct directories. Do not dump everything in the root folder. Main directory where all parent folders should be is ***addons/ComponentPack/***

- **Strict Isolation**: Every single new component must have its own dedicated folder. Do not mix assets from different objects into the same directory.

- **Textures and Sprites Paths**: Must be placed strictly inside the matching folders using the following directory structure:

[ComponentName]/Textures/SpriteFrames/

[ComponentName]/Textures/Sprites/

## How to Submit Your Changes

If you are new to GitHub or open-source, don't worry! Here is the step-by-step process to submit your work:

1. **Fork the Repository:** Click the "Fork" button at the top right of this GitHub page to create a personal copy of this project on your own account.
2. **Create a Branch:** Download your fork to your computer (using GitHub Desktop or the command line). Create a new, cleanly named branch for your specific addition. 
	* *CLI command:* `git checkout -b feature/your-component-name`
3. **Make Your Changes:** Add your new folders, code, or assets into the Godot project. Ensure you follow all the naming and architecture rules above.
4. **Commit:** Save your changes with a clear, short description of exactly what you built.
	* *CLI command:* `git commit -m "Added YourComponentName node"`
5. **Push & Pull Request:** Upload (push) your branch back to your GitHub account. Then, go to the original repository and click the green "Compare & pull request" button to submit your assets for review.
	* *CLI command:* `git push origin feature/your-component-name`

## Pull Request Requirements

When you open a PR, you MUST include:

A brief description of what you added or fixed.

(***Optional***) At least one screenshot of your asset rendered or placed inside the Godot engine to prove it works. (To speed up the merging process).

If your PR does not meet these guidelines, I will request changes before merging it.