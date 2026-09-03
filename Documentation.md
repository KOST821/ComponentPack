# Component Asset Pack Documentation

## Contents

- ![gravity](/Gravity/gravity.svg) [Gravity](#gravity-)

- ![drag_and_drop](/DragAndDrop/chess_pawn.svg) [Drag and Drop](#drag-and-drop-)

- [Health](#health--)
    * ![heart2d](/Health/2D/heart.svg) [Health2D](#health2d-)
    * ![heart3d](/Health/3D/heart.svg) [Health3D](#health3d-)

- ![scene_spawner](/SceneSpawner/file_plus.svg) [SceneSpawner](#scenespawner-)

- [Damage System](#damage-system----)
    * ![hitbox2d](/HitAndHurtBox/2D/HitBox/swords.svg) ![hitbox3d](/HitAndHurtBox/3D/HitBox/swords.svg) [Hitboxes](#hitboxes--)
    * ![hurtbox2d](/HitAndHurtBox/2D/HurtBox/shield.svg) ![hurtbox3d](/HitAndHurtBox/3D/HurtBox/shield.svg) [Hurtboxes](#hurtboxes--)

- ![input_buffer_icon](/InputBuffer/alarm_clock.svg) [InputBuffer](#inputbuffer-)

- [FiniteStateMachine](#finitestatemachine)
    * ![fsm_nb_icon](/FiniteStateMachine/Classic/cog.svg) ![state_icon_nb](/FiniteStateMachine/Classic/box.svg) [FiniteStateMachine (Node-Based)](#finitestatemachine-node-based)
    * ![fsm_ub_icon](/FiniteStateMachine/UserBased/bot.svg) [FiniteStateMachine (User-Based)](#finitestatemachine-user-based)

- ![squash_anim_icon](/SquashAnimation/gobot.svg) [SquashAnimation](#squashanimation)

- [Glossary](#glossary)

<br> <br>

# Gravity <img width="24" height="24" alt="gravity" src="/Gravity/gravity.svg"/> 

This component adds gravity to a Node.

## Basic Use

If we have a *[CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html)* with this script: <br>

```GDScript
extends CharacterBody2D

const SPEED: float = 500.0

func _physics_process(delta: float) -> void:
    # Get the input direction and handle the movement.
    var direction := Input.get_axis("ui_left", "ui_right")

    if direction:
        velocity.x = direction * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)

    move_and_slide()
```

Attaching a **Gravity** Node to it, and adjusting in the editor the <code> gravity</code> variable to your liking, if you add this line of code: <br>

<code> if not is_on_floor(): velocity.y = gravity.get_gravity(delta,velocity.y)</code> <br> 
 
***we give gravity to our player!***

So our code now is: <br>

```GDScript
extends CharacterBody2D

@export var gravity:Gravity # NOTE: This is the instance of the component.

const SPEED:float = 500.0

func _physics_process(delta:float) -> void:
    # Get the input direction and handle the movement.
    var direction := Input.get_axis("ui_left", "ui_right")

    if direction:
        velocity.x = direction * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
        
    # CRITICAL: Here we apply the gravity to the player!
    if not is_on_floor():
        velocity.y = gravity.get_gravity(delta, velocity.y)

    move_and_slide()
```

## Advanced Settings

The <code>get_gravity(...)</code> function accepts optional parameters to fine-tune how your Node falls.

### Max Falling Speed (Terminal Velocity)

In the example to prevent your character from falling infinitely fast, provide a **maximum falling speed** as the third argument. If we want the max falling speed to be 450.0, we edit the line like this:

```GDScript
if not is_on_floor():
    velocity.y = gravity.get_gravity(delta, velocity.y)
```

And make it like this:

```GDScript
if not is_on_floor():
    velocity.y = gravity.get_gravity(delta, velocity.y, 450.0)
```

### Descending Gravity Factor (Fall Multiplier)

To make jumps feel less "floaty", you can apply a multiplier to the gravity only when the entity is falling downwards. Values above 1.0 create heavier, snappier falls (commonly seen in platformers).

```GDScript
if not is_on_floor():
    velocity.y = gravity.get_gravity(delta, velocity.y, 450.0, 1.5)
```

Keep in mind that if you want to have **descending gravity factor** but not a [**maximum falling speed**](#max-falling-speed-terminal-velocity) you just add <code> 0.0 </code> to the 3rd value (**maximum falling speed**).

<br>

# Drag And Drop <img width="24" height="24" alt="drag_and_drop" src="/DragAndDrop/chess_pawn.svg"/>

This component is used to add a drag and drop feature to an [*CollisionObject2D*](https://docs.godotengine.org/en/stable/classes/class_collisionobject2d.html).

## Use

If we had a [*CharacterBody2D*](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html) with no scripts, and as children a [**CollisionShape2D**](https://docs.godotengine.org/en/stable/tutorials/physics/collision_shapes_2d.html) and a **drag and drop** when you "grab" the [*CharacterBody2D*](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html) inside the [CollisionShape2D](https://docs.godotengine.org/en/stable/tutorials/physics/collision_shapes_2d.html) you can move it! To work you must look at those 6 things:

<ol>
    <li> User </li>
    <li> Drop Sensor </li>
    <li> Behavior </li>
    <li> Drop Zone Group </li>
    <li> Input Start Action </li>
    <li> Input End Action </li>
    <li> Tween Trans </li>
</ol>

When all of these are filled you can use the **drag and drop**!

### 1. User

The Node who uses the component, must be a [CollisionObject2D](https://docs.godotengine.org/en/stable/classes/class_collisionobject2d.html) to receive mouse events.

> [!NOTE]
> If empty the parent will be placed, assuming the parent is [CollisionObject2D](https://docs.godotengine.org/en/stable/classes/class_collisionobject2d.html). If empty at last, the game will give you an <font color="red"> ***Error***</font>.


### 2. Drop Sensor

Drop Sensor is an [*Area2D*](https://docs.godotengine.org/en/stable/classes/class_area2d.html) Node. It is the [*Area2D*](https://docs.godotengine.org/en/stable/classes/class_area2d.html) responsible for detecting drop zones. If empty, assumes the [User](#1-user) itself is the [*Area2D*](https://docs.godotengine.org/en/stable/classes/class_area2d.html). **Required** if your User is a [*CharacterBody2D*](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html) and you are using snapping behaviors.

### 3. Behavior

Defines how the [user](#1-user) node behaves when the drag has ended. You can assign 3 values:

<br>

- [Drop Anywhere](#drop-anywhere)
- [Snap To Zone](#snap-to-zone)
- [Return If No Zone](#return-if-no-zone)

<br>

#### Drop anywhere

Stays exactly where you let go.

#### Snap to zone

Snaps to a specific [zone](#zones) if dropped on it, otherwise stays where you let go.

#### Return if no zone

Snaps to a specific [zone](#zones), but returns back to start if missed.

### 4. Drop Zone Group

The name of the **group** that [zones](#zones) will be.

> [!NOTE]
> If empty the placeholder will be placed.

### 5. Input Start Action

The action name that will be used to start draging.

> [!NOTE]
> If empty the placeholder will be placed.

**For example:**

You go to ***Project → Project Settings → Input Map*** here you create an action and name it, lets go for *start_drag* with left mouse click. Now you have an action named *start_drag* and the left click as the action!

now you just go to ***Input Start Action*** and add the name of the action in the editor, so **start_drag**.

### 6. Input End Action

The action name that will be used to cancel draging.

> [!NOTE]
> If empty the placeholder will be placed.

**For example:**

You go to ***Project → Project Settings → Input Map*** here you create an action and name it, lets go for *cancel_drag* with right mouse click. Now you have an action named *cancel_drag* and the right click as the action!

now you just go to ***Input End Action*** and add the name of the action in the editor, so **cancel_drag**.

### 7. Tween Trans

The trans type of the tween animation that will be played when drag is **canceled** or **invalid**.

## Zones

Zone is an [*Area2D*](https://docs.godotengine.org/en/stable/classes/class_area2d.html) Node. For an [*Area2D*](https://docs.godotengine.org/en/stable/classes/class_area2d.html) to be a zone we need to do something first! In the inspector you go to **Groups** tab and add a new group, you can amke it global or keep it scene based doesn't matter! Give it a name e.g. ***zone_group***. In that group you add every [*Area2D*](https://docs.godotengine.org/en/stable/classes/class_area2d.html) that you want to be a zone.

**You are done!** Now by just adding a [*CollisionShape2D*](https://docs.godotengine.org/en/stable/tutorials/physics/collision_shapes_2d.html) and giving it a shape you have a ****ZONE****!

<br>

# Health <img width="24" height="24" alt="health2d" src="/Health/2D/heart.svg"/> <img width="24" height="24" alt="health3d" src="/Health/3D/heart.svg"/>
**Health** is a *dimention* component, it has a 2D and 3D variation. They have the same use, with one key defference in variables:

|Variable|Health2D|Health3D|
| :------: | :------: | :----: |
|User    |[Node2D](https://docs.godotengine.org/en/stable/classes/class_node2d.html#node2d)|[Node3D](https://docs.godotengine.org/en/stable/classes/class_node3d.html)|
|Max Health|[float](https://docs.godotengine.org/en/stable/classes/class_float.html#float)|[float](https://docs.godotengine.org/en/stable/classes/class_float.html#float)|
|Starting Health Per|[float](https://docs.godotengine.org/en/stable/classes/class_float.html#float)|[float](https://docs.godotengine.org/en/stable/classes/class_float.html#float)|
|Post Death Action|[enum (int)](https://docs.godotengine.org/en/stable/tutorials/best_practices/data_preferences.html#enumerations-int-vs-string)|[enum (int)](https://docs.godotengine.org/en/stable/tutorials/best_practices/data_preferences.html#enumerations-int-vs-string)|
|Drop On Death|[PackedScene](https://docs.godotengine.org/en/4.4/classes/class_packedscene.html)|[PackedScene](https://docs.godotengine.org/en/4.4/classes/class_packedscene.html)|
|Distance Above Floor|*Not included*|[float](https://docs.godotengine.org/en/stable/classes/class_float.html#float)|

As you can see there is one more variable in 3D variation of the component!


## Health2D <img width="24" height="24" alt="health2d" src="/Health/2D/heart.svg"/>

A component that counts the **health** of a Node.

### Setup Properties
---
To set a **Health2D** you need to add 5 variables:

1. User
2. Max Health
3. Starting Health Per
4. Post Death Action
5. Drop On Death

#### 1. User

User is the one using the component, the one that health is related to.

> [!NOTE]
> If empty the parent will be added. If parent is not a valid type there will be an <font color="red"> ***Error***</font>

#### 2. Max Health

The maximum health capacity.

#### 3. Starting Health Per

The percentage of max health the component starts with. (e.g., if max health is 100.0 and this is 40.0, the entity starts with 40.0 health).

#### 4. Post Death Action

What happens after [death](#death-when-health-reaches-00). It can be 2 things:

- [Restart Scene](#restart-scene)
- [Destroy Node](#destroy-node)

##### Restart Scene

Reloads the current active scene tree.

##### Destroy Node

Queues the [User](#1-user-1) node for deletion and spawns the [drop item](#5-drop-on-death) (if any).

#### 5. Drop On Death

A [*PackedScene*](https://docs.godotengine.org/en/4.4/classes/class_packedscene.html) to spawn at the [User's](#1-user-1) location upon [death](#death-when-health-reaches-00). If null, nothing drops.

### Signals
---

This component comes with 4 signals:

1. [damage_taken](#damage_taken)
2. [health_gained](#health_gained)
3. [died](#died)
4. [health_changed(current_health, max_health)](#health_changedcurrent_health-max_health)

#### damage_taken

Emitted when the [User](#1-user-1) loses health.

#### health_gained

Emitted when the [User](#1-user-1) is healed.

#### died

Emitted when [dies](#death-when-health-reaches-00).

#### health_changed(current_health, max_health)

Emitted any time health is modified, passing the new values.

### How to use
----

Now to use a **Health2D** you just add a reference to the **health** component on [Users](#1-user) script like this:

<code>@export var health:Health2D</code>

Now to **take damage** you just call: <code> health.take_damage(damage) </code> where "*damage*" is the amout of damage you want to deal, to **heal** you just write: <code>health.heal(heal_amout)</code> where "*heal_amount*" the amount of health you want to be replenished.

## Health3D <img width="24" height="24" alt="health3d" src="/Health/3D/heart.svg"/>

**Health3D** works exactly like **Health2D** but you dont reference 2D but 3D. Though the new variable is just a float that will be just how far above (or below if number is lower than 0.0) will the [item](#5-drop-on-death) be spawned.

# SceneSpawner <img width="24" height="24" alt="scene_spawner" src="/SceneSpawner/file_plus.svg"/>

It spawns one spesific scene to the game!

## Setup Properties

To work it needs 3 variables to be set:
1. Scene
2. Spawn Top Level
3. Match Transform Top Level

### 1. Scene

Accepts a [PackedScene](https://docs.godotengine.org/en/4.4/classes/class_packedscene.html), this is the scene that will be spawned.

### 2. Spawn Top Level

If ****true**** the *New Node* will be spawned independently from the other [Nodes](https://docs.godotengine.org/en/4.4/classes/class_node.html).

### 3. Match Transform Top Level

If ****true**** the *New Node* will have the transform of the parent [Node](https://docs.godotengine.org/en/4.4/classes/class_node.html).

## Basic Use

Let's say you have a scene that you want to *instantiate* and a scene that you want to *instatiate into*.

> [!NOTE]
> From now on the scene you want to *instatiate* will be reffered as ***UI*** and the scene you want to *instantiate into* will be reffered as ***menu***.

To instantiate the *UI* to *menu* you just add the Scene spawner as a *****CHILD***** of *menu* and attach the *UI* to the [scene](#1-scene) variable. Then you add a refferance of the **SceneSpawner** in the *menu's* script like this: <code>@export var scene_spawner:SceneSpawner</code> and now by calling <code>scene_spawner.spawn(self)</code> you are spawning the *UI* to the menu.

> [!NOTE]
> In that case inside <code>scene_spawner.spawn(...)</code> we added self because we wanted to add the UI to the script we were writing. We write inside the scene we want to *instantiate into*. If that scene is the **SceneSpawner's** parent we can leave it empty.

Now based of how your boolian variables *([spawn top level](#2-spawn-top-level) and [match transform top level](#3-match-transform-top-level))* are assigned there will be different instantiations!

- If both of them are ****true**** the *scene you want to spawn* will be spawned to the scene as a *****CHILD***** of the root node but it will have the [transform](#transform-the-global-position-and-rotation) of the node we have passed inside the spawn, *menu* in this case.
- If [spawn top level](#2-spawn-top-level) is only ****true**** the *scene you want to spawn* will be spawned to the scene as a *****CHILD***** of the root node but it will have the default [transform](#transform-the-global-position-and-rotation) (position: 0.0 and rotation: 0.0).
- If none of them are ****true**** the *scene you want to spawn* will be spawned to the scene as a *****CHILD***** of the node you passed in <code>*spawn*</code> and it will have the [transform](#transform-the-global-position-and-rotation) of the node we have passed inside the spawn, *menu* in this case.

## Advanced use

There are a lot of times we want to run a code to the scene we are adding, in this case you do not use: <code>scene_spawner.spawn(...)</code> but you use:

```GDScript
var ui:= scene_spawner.instantiate()
#Here you run the code you want
#Find where you want to instantiate for me is menu
menu.add_child(ui)
```

# Damage System <img width="24" height="24" alt="hitbox2d" src="/HitAndHurtBox/2D/HitBox/swords.svg"> <img width="24" height="24" alt="hitbox3d" src="/HitAndHurtBox/3D/HitBox/swords.svg"> <img width="24" height="24" alt="hurtbox2d" src="/HitAndHurtBox/2D/HurtBox/shield.svg"> <img width="24" height="24" alt="hurtbox3d" src="/HitAndHurtBox/3D/HurtBox/shield.svg">

The **Damage System** is a decoupled pair of components ([HitBoxes](#hitboxes--) and [HurtBoxes](#hurtboxes--)) available in both 2D and 3D variations. They rely on Godot's [Area2D](https://docs.godotengine.org/en/stable/classes/class_area2d.html#area2d) or [Area3D](https://docs.godotengine.org/en/stable/classes/class_area3d.html) nodes to detect overlap and safely pass damage values. To function, a Damage dealer ([HitBox](#hitboxes--)) must collide with a Damage receiver ([HurtBox](#hurtboxes--)) of the matching dimension.

## HitBoxes <img width="24" height="24" alt="hitbox2d" src="/HitAndHurtBox/2D/HitBox/swords.svg"> <img width="24" height="24" alt="hitbox3d" src="/HitAndHurtBox/3D/HitBox/swords.svg">

**HitBoxes** are the active damage dealers. Attach a ***HitBox*** component to anything that causes harm (e.g., a sword, a bullet, a trap).

### Basic use

---

To work you just grab the correct dimensional node, *if it is a 2D node you grab the 2D **hitbox**, else if it is a 3D node you grab the 3D **hitbox***, you adjust the damage it will deal in the inspector and you are done!
Add the correct dimensional node, *if it is a 2D node you grab the 2D **hitbox**, else if it is a 3D node you grab the 3D **hitbox***, as a child of your damage-dealing entity. Add a Godot [CollisionShape2D](https://docs.godotengine.org/en/stable/tutorials/physics/collision_shapes_2d.html#collision-shapes-2d) or [CollisionShape3D](https://docs.godotengine.org/en/stable/tutorials/physics/collision_shapes_3d.html#collision-shapes-3d)  to define its physical area, and adjust the Damage property in the inspector.

> [!TIP]
> The [Control](https://docs.godotengine.org/en/stable/classes/class_control.html#control) nodes are counted as 2D nodes.

### Advance use

---

You can always modify the damage through code by adding the instance of the **hitbox** to the code like:

```GDScript
@export var hitbox:HitBox2D # Or HitBox3D depending what you use.
```

and to change the damage just write:

```GDScript
hitbox.damage = amount # amout is a float number, you can always write it as it is e.g. 4.0
```

## HurtBoxes <img width="24" height="24" alt="hurtbox2d" src="/HitAndHurtBox/2D/HurtBox/shield.svg"> <img width="24" height="24" alt="hurtbox3d" src="/HitAndHurtBox/3D/HurtBox/shield.svg">

**HurtBoxes** are the passive receivers that [HitBoxes](#hitboxes--) search for. They act as a bridge between the physical collision and your entity's health logic.

### Setup Properties

---

To setup we need to adjust 2 variables:
1. [Health Counter](#health-counter)
2. [Method](#method)

#### Health Counter

Who is tracking the health.

#### Method

The name of the method that reduces the health.

> [!NOTE]
> If empty it keeps the placeholder.

#### EXAMPLE

Let's say for example we have the [Health Component](#health--) as a health tracker. We add this component as the *Health Counter*. To the *Method* if we open the script of the component we will find this function:

```GDScript
func take_damage(amount:float)->void:
	health -= amount
	
	health_changed.emit(health,max_health)
	damage_taken.emit()
	
	if health <= 0:
		_death()
```

As you can see in the first line in this function we remove the damage:

```GDScript 
func take_damage(amount:float)->void:
	health -= amount
    ...
```

So in *Method* we just copy and paste the name, DO NOT ADD PARENTHESES! If your player script has that kind of function you just add this node and name to the correct variable spots.

# FlipSprite2D  <img width="24" height="24" alt="flip_sprite2d" src="/FlipSprite/mirror_xy.svg">

The **FlipSprite2D** is responsible for flipping the sprite.

## Setup Properties

The variables you have to modify for it to work are 5:

1. [Sprite](#sprite)
2. [Flip H](#flip-h)
3. [Flip V](#flip-v)
4. [Default H Direction](#default-h-direction)
5. [Default V Direction](#default-v-direction)

### Sprite

Flips a [Sprite2D](https://docs.godotengine.org/en/stable/classes/class_sprite2d.html#sprite2d) or an [AnimatedSprite2D](https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html#class-animatedsprite2d) towards the direction of a [Vector2](https://docs.godotengine.org/en/stable/classes/class_vector2.html#vector2) position.

The Sprite node that will be flipped.

> [!NOTE]
>It is defined as a [Node2D](https://docs.godotengine.org/en/stable/classes/class_node2d.html#node2d) but it needs to be either a [Sprite2D](https://docs.godotengine.org/en/stable/classes/class_sprite2d.html#sprite2d) or an [AnimatedSprite2D](https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html#class-animatedsprite2d.)

### Flip H

If <code>true</code>, the [Sprite](#sprite) can be flipped horizontally.

### Flip V

If <code>true</code>, the [Sprite](#sprite) can be flipped vertically.

### Default H Direction

The default Horizontal face direction.

### Default V Direction

The default Vertical face direction.

## Basic Use

To use the component, attach it as a child of your entity, assign your [Sprite](#sprite) node in the inspector, and ensure the *Default Directions* match the artwork's original orientation.

Call the <code>flip_sprite_towards()</code> method dynamically in your movement script. For example, to make a character always face the mouse cursor:

```GDScript
@export var flipper: FlipSprite2D # Get component instance

func _process(delta: float) -> void:
    flipper.flip_sprite_towards(get_global_mouse_position())
```

# InputBuffer <img width="24" height="24" alt="buffered_icon" src="/InputBuffer/alarm_clock.svg">

**InputBuffer** is holding a timer to buffer an action.

## Setup Properties

To work you *just* need to setup the variables. There are only 2 variables to be set:

1. [Action Name](#action-name)
2. [Buffer time](#buffer-time)

### Action Name

After you create the action you want to buffer, by going to ***Project → Project Settings → Input Map***, you take the action's name and add it in this variable.

> [!NOTE]
> If empty the placeholder will be added.

### Buffer time

The time where this action will be buffered.

> [!TIP]
> This time is usally lower than <code>0.5</code>.

You can always change the value through code by writing:

```GDScript
@export var buffer:InputBuffer # Get component instance

func change_buffer_time() -> void:
    buffer.buffer_time = amount # amount is the time of buffer you want to give, you can always write the number e.g. 0.23.
```

# FiniteStateMachine

This asset pack is providing you with 2 **FiniteStateMachines**, one is [Node](https://docs.godotengine.org/en/stable/classes/class_node.html#node) based and one is [User](#user-1) based. A **FiniteStateMachine** is used to keep track of the current state of a [Node](https://docs.godotengine.org/en/stable/classes/class_node.html#node). A **FiniteStateMachine** is built by 2 nodes, the State node and the FiniteStateMachineManager node.

## FiniteStateMachine Node based

### FiniteStateMachineManager <img width="24" height="24" alt="finite_state_machinenb" src="/FiniteStateMachine/Classic/cog.svg">

It keeps track of the current [State](#state-). When a [State](#state-) is active it runs code while a [State](#state-) is inactive the code is not running. In the current Manager you only need to add the [User](#user) and the [Initial State](#initial-state).

#### User

Whose [States](#state-) this **Manager** is tracking.

> [!NOTE]
> If empty it gets the parent.

#### Initial State

The [State](#state-) the [User](#user) is starting from.

### State <img width="24" height="24" alt="finite_state_machinenb_state" src="/FiniteStateMachine/Classic/box.svg">

In states you make the logic you want to run, when the [User](#user) is in this **State**. Each **State** has a spesific way of work.

#### Setup Properties

When you add a **State** node into the [SceneTree](https://docs.godotengine.org/en/stable/classes/class_scenetree.html#class-scenetree) first you *extend the script* and then you add to the "States That Can Change" variable [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html#dictionary) a [String](https://docs.godotengine.org/en/stable/classes/class_string.html#string) and an other State Node.

#### How to code a State

Starting you create a [Script](https://docs.godotengine.org/en/stable/classes/class_script.html#script) that <code>extends StateNB # (NB) = Node Based </code> and you give it a <code>class_name</code>.

If you want to run a code when you enter a state you do not use <code>func _ready() -> void: pass</code> function but you use the:

```GDScript
func _enter_state()->void:
	pass # Add your _ready logic here.
```

Same and when you leave a state, you write:

```GDScript
func _exit_state()->void:
	pass # Add your leaving logic here.
```

Functions like <code>_process</code> or <code>_physics_process</code> are replaced with:

```GDScript
func _update(_delta:float)->void:
	pass # Add your _process logic here.

func _physics_update(_delta: float) -> void:
	pass # Add your _physics_process logic here.
```

For inputs you write:

```GDScript
func unhandled_input(_event:InputEvent)->void:
	pass # Add your input logic here.
```

*Transitioning* between **States** is easy, you write just:

```GDScript
func _transition()->void:
	pass # Add your transition  logic here.
```

***Example:***

If you have a tree like this:

![player_tree_icon](/Examples/tree_NB.png)

Let's say we keep track of Player's States and we want to be Idle first then, we setup the *FiniteStateMachineNB* like this:

![cog_icon](/Examples/manager_NB.png)

Now to the "Idle" State we *extend the script* and we want to be able to run if we are in Idle state, so we connect the move to the [Dictionary](https://docs.godotengine.org/en/stable/classes/class_dictionary.html#dictionary).

![state_icon](/Examples/State_NB.png)

So now is time to write an *Idle.gd*!

```GDScript
extends StateNB
class_name IdleState

func _enter_state()->void:
	user.velocity = Vector2.ZERO

func _physics_update(_delta: float) -> void:
	# Check for transitions!
	_transition()

func _transition()->void:
	var direction:Vector2 = user.get_axis("ui_left","ui_right")
	
	# Check if we are moving.
	if direction != Vector2.ZERO:
        switch_state.emit(states_that_can_change[&"Move"]) # It must match exactly what you entered into the Dictionary.
```

## FiniteStateMachine User based

### FiniteStateMachineManager <img width="24" height="24" alt="finite_state_machinenb_state" src="/FiniteStateMachine/UserBased/bot.svg">

Unlike the [Node-based FSM](#finitestatemachine-node-based), the **User-Based FSM** dynamically creates and destroys states in memory using [<code>RefCounted</code>](https://docs.godotengine.org/en/latest/classes/class_refcounted.html#) objects. [States](#state-1) are never added to the [SceneTree](https://docs.godotengine.org/en/stable/classes/class_scenetree.html#class-scenetree), making this approach extremely lightweight. The user (e.g., the Player script) dictates when state transitions occur.

#### User

Whose [States](#state-1) this **Manager** is tracking.

> [!NOTE]
> If empty it gets the parent.

### State

In states you make the logic you want to run, when the [User](#user) is in this **State**. Each **State** has a spesific way of work. These **States** are never added to the [SceneTree](https://docs.godotengine.org/en/stable/classes/class_scenetree.html#class-scenetree).

#### How to code a State

Starting you create a [Script](https://docs.godotengine.org/en/stable/classes/class_script.html#script) that <code>extends StateUB # (UB) = User Based </code> and you give it a <code>class_name</code>.

If you want to run a code when you enter a state you do not use <code>func _ready() -> void: pass</code> function but you use the:

```GDScript
func _enter_state()->void:
	pass # Add your _ready logic here.
```

Same and when you leave a state, you write:

```GDScript
func _exit_state()->void:
	pass # Add your leaving logic here.
```

Functions like <code>_process</code> or <code>_physics_process</code> are replaced with:

```GDScript
func _update(_delta:float)->void:
	pass # Add your _process logic here.

func _physics_update(_delta: float) -> void:
	pass # Add your _physics_process logic here.
```

For inputs you write:

```GDScript
func unhandled_input(_event:InputEvent)->void:
	pass # Add your input logic here.
```

*Transitioning* between **States** is happening through the user.

***Example:***

If you have a tree like this:

![player_tree_icon](/Examples/tree_UB.png)

Let's say we keep track of Box's States then, we setup the *FiniteStateMachineUB* like this:

![bot_icon](/Examples/machine_UB.png)

Now to the "Box" we *create a script*.

![create_script_icon](/Examples/create_sqp_UB.png)

***Let's create a small machine!***

To start let's create a *Idle.gd* that <code>extends StateUB</code>.

```GDScript
extends StateUB
class_name IdleState

func _enter_state() -> void:
	user.velocity = Vector3.ZERO
```

Now let's create the *Move.gd* <code>extends StateUB</code>.

```GDScript
extends StateUB
class_name MoveState


const SPEED = 5.0

# Handle movement
func _physics_update(delta: float) -> void:
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (user.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		user.velocity.x = direction.x * SPEED
		user.velocity.z = direction.z * SPEED
	else:
		user.velocity.x = move_toward(user.velocity.x, 0, SPEED)
		user.velocity.z = move_toward(user.velocity.z, 0, SPEED)

	user.move_and_slide()
```

So now is time to write an *Player3D.gd*!

```GDScript
extends CharacterBody3D

@export var fsm: FiniteStateMachineUB # The instance of the Machine.

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir:
        # There is a movement. So we need to go to MoveState
        fsm.change_state(MoveState) # MoveState is the class_name of the Move.gd!
    else:
        fsm.change_state(IdleState) # IdleState is the class_name of the Idle.gd!
```

# SquashAnimation

This component applies a fully customizable, mathematical squash-and-stretch animation to a 2D [Node](https://docs.godotengine.org/en/stable/classes/class_node.html#node). Because it directly overrides the <code>scale</code> and <code>rotation</code> properties of its user every frame, it is highly recommended to apply this component strictly to visual [Nodes](https://docs.godotengine.org/en/stable/classes/class_node.html#node) (like a [Sprite2D](https://docs.godotengine.org/en/stable/classes/class_sprite2d.html#sprite2d) or [TextureRect](https://docs.godotengine.org/en/stable/classes/class_texturerect.html#texturerect)) rather than root physics bodies.

> [!TIP]
> The [Control](https://docs.godotengine.org/en/stable/classes/class_control.html#control) nodes are counted as 2D nodes.

## Setup Properties

### Basic Variables

|Name|Default|Description|Type|
|:---| :---: |   :---:   |---:|
|User|`null`|The [Node2D](https://docs.godotengine.org/en/stable/classes/class_node2d.html#node2d) or [Control](https://docs.godotengine.org/en/stable/classes/class_control.html#control) node that will be animated. If left empty, it will default to its parent.|[Node](https://docs.godotengine.org/en/stable/classes/class_node.html#node)|
|Speed| 3.0|How fast the *animation* progresses.|[float](https://docs.godotengine.org/en/stable/classes/class_float.html#float)|
|Looping|`true`|If `false`, the *animation* stops and resets after the ***Duration*** is reached.|[bool](https://docs.godotengine.org/en/latest/classes/class_bool.html#)|
|Duration| 1.0|How long the *animation* lasts if ***Looping*** is disabled. For **infinite** time ***Duration*** must be `-1.0`|[float](https://docs.godotengine.org/en/stable/classes/class_float.html#float)|
|Enable|`false`|Toggles the component on or off. When disabled, the user's transform resets to its base state.|[bool](https://docs.godotengine.org/en/latest/classes/class_bool.html#)|
|Editor Disable|`true`|Prevents the *animation* from playing continuously inside the Godot editor viewport while you are working.|[bool](https://docs.godotengine.org/en/latest/classes/class_bool.html#)|

### Advanced Variables

Deformation Limits (Squash & Stretch)The component calculates the squash/stretch effect using a mathematical midpoint and amplitude based on your limits:

$amplitude = \frac{Max Point - Lowest Point}{2.0}$

$midpoint = \frac{Max Point + Lowest Point}{2.0}$

#### X and Y Axis Properties
Both the X and Y axes share identical configuration options to independently control horizontal and vertical deformation.

|Name|Default|Description|Type|
|:---| :---: |   :---:   |---:|
|Lowest Point| 0.9 | The minimum scale multiplier during the *animation* cycle.|[float](https://docs.godotengine.org/en/stable/classes/class_float.html#float)|
|Max Point| 1.1| The maximum scale multiplier during the *animation* cycle.|[float](https://docs.godotengine.org/en/stable/classes/class_float.html#float)|
|Type| `SINE` / `COSINE`| The mathematical wave function used to drive the scale.|[enum (int)](https://docs.godotengine.org/en/stable/tutorials/best_practices/data_preferences.html#enumerations-int-vs-string)|

#### Wave Types

You can assign different wave equations to the axes to create distinct bouncing or breathing rhythms:
- SINE: Smooth, continuous wave.

    $midpoint + amplitude \cdot \sin(time)$

- COSINE: Smooth, continuous wave, offset from Sine.

    $midpoint + amplitude \cdot \cos(time)$

- TANGENT: Sharp, snapping wave. Clamped between -1.0 and 1.0.

    $midpoint + amplitude \cdot \tan(time)$

- SINE AND COSINE: A complex, varied wave.
    $midpoint + 2.0 \times amplitude \cdot \sin(time) \cdot \cos(time)$  

- BOUNCE: A specialized arc that creates a sharp impact at the bottom and "hang time" at the top.
    $Lowest Point + 2.0 \times amplitude \cdot (\vert{}\sin(time)\vert{})^2$  

#### Rotation Limits (Wobble)

|Name|Default|Description|Type|
|:---| :---: |   :---:   |---:|
|Target Tilt Degrees| 15.0 | The maximum rotation angle (in degrees) reached during the *wobble*.|[float](https://docs.godotengine.org/en/stable/classes/class_float.html#float)|
|Tilt Speed| 10.0 | How quickly the node interpolates toward the target tilt.|[float](https://docs.godotengine.org/en/stable/classes/class_float.html#float)|
|Wobble Frequency| 0.5|The frequency of the sine wave driving the rotation.|[float](https://docs.godotengine.org/en/stable/classes/class_float.html#float)|

## Use

To enable the component, starting the animation from time 0.0. use the function:

```GDScript
@export var squash_anim: SquashAnimation # Get the instance.

func _on_player_landed() -> void: # A random function in the script you want to call.
    squash_anim.play() # Plays animation.
``` 

Ideal for triggering from other scripts (e.g., calling it when a player lands a jump).

To disable the component and immediately reset the user node to its original base scale and rotation. We use:

```GDScript
@export var squash_anim: SquashAnimation # Get the instance.

func cancel_animation() -> void: # A random function in the script you want to call.
    squash_anim.stop() # Stops animation.
``` 

# Glossary

###### death: when health reaches <code>0.0</code>.

###### transform: the global position and rotation.