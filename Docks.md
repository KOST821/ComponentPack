# How to use

- ![gravity](/Gravity/gravity.svg) [Gravity](#gravity-)
- ![drag_and_drop](/DragAndDrop/chess_pawn.svg) [Drag and Drop](#drag-and-drop-)
- [Health](#health--)
    * ![heart2d](/Health/2D/heart.svg) [Health2D](#health2d)
    * ![heart3d](/Health/3D/heart.svg) [Health3D](#health3d)
- ![scene_spawner](/SceneSpawner/file_plus.svg) [SceneSpawner](#scenespawner-)
- [Glossary](#glossary)

<br> <br>

# Gravity <img width="24" height="24" alt="gravity" src="/Gravity/gravity.svg"/> 

This component adds gravity to a Node.

## Basic Use

If we have a *[CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html)* with this script: <br>

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

The Node who uses the component, must be a [CollisionObject2D](https://docs.godotengine.org/en/stable/classes/class_collisionobject2d.html) to receive mouse events. If empty the parent will be placed, assuming the parent is [CollisionObject2D](https://docs.godotengine.org/en/stable/classes/class_collisionobject2d.html). If empty at last, the game will give you an <font color="red"> ***Error***</font>.

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

The name of the **group** that [zones](#zones) will be. If empty the placeholder will be placed.

### 5. Input Start Action

The action name that will be used to start draging. If empty the placeholder will be placed. For example:

You go to ***Project → Project Settings → Input Map*** here you create an action and name it, lets go for *start_drag* with left mouse click. Now you have an action named *start_drag* and the left click as the action!

now you just go to ***Input Start Action*** and add the name of the action in the editor, so **start_drag**

### 6. Input End Action

The action name that will be used to cancel draging. If empty the placeholder will be placed. For example:

You go to ***Project → Project Settings → Input Map*** here you create an action and name it, lets go for *cancel_drag* with right mouse click. Now you have an action named *cancel_drag* and the right click as the action!

now you just go to ***Input End Action*** and add the name of the action in the editor, so **cancel_drag**

### 7. Tween Trans

The trans type of the tween animation that will be played when drag is **canceled** or **invalid**.

## Zones

Zone is an [*Area2D*](https://docs.godotengine.org/en/stable/classes/class_area2d.html) Node. For an [*Area2D*](https://docs.godotengine.org/en/stable/classes/class_area2d.html) to be a zone we need to do something first! In the inspector you go to **Groups** tab and add a new group, you can amke it global or keep it scene based doesn't matter! Give it a name e.g. ***zone_group***. In that group you add every [*Area2D*](https://docs.godotengine.org/en/stable/classes/class_area2d.html) that you want to be a zone.

**You are done!** Now by just adding a [*CollisionShape2D*](https://docs.godotengine.org/en/stable/tutorials/physics/collision_shapes_2d.html) and giving it a shape you have a ****ZONE****!

<br>

# Health <img width="24" height="24" alt="health2d" src="/Health/2D/heart.svg"/> <img width="24" height="24" alt="health3d" src="/Health/3D/heart.svg"/>
Health is a *dimention* component, it has a 2D and 3D variation. They have the same use with one key defference in variables:

|Variable|Health2D|Health3D|
| :------: | :------: | :----: |
|User    |[Node2D](https://docs.godotengine.org/en/stable/classes/class_node2d.html#node2d)|[Node3D](https://docs.godotengine.org/en/stable/classes/class_node3d.html)|
|Max Health|[float](https://docs.godotengine.org/en/stable/classes/class_float.html#float)|[float](https://docs.godotengine.org/en/stable/classes/class_float.html#float)|
|Starting Health Per|[float](https://docs.godotengine.org/en/stable/classes/class_float.html#float)|[float](https://docs.godotengine.org/en/stable/classes/class_float.html#float)|
|Post Death Action|[enum (int)](https://docs.godotengine.org/en/stable/tutorials/best_practices/data_preferences.html#enumerations-int-vs-string)|[enum (int)](https://docs.godotengine.org/en/stable/tutorials/best_practices/data_preferences.html#enumerations-int-vs-string)|
|Drop On Death|[PackedScene](https://docs.godotengine.org/en/4.4/classes/class_packedscene.html)|[PackedScene](https://docs.godotengine.org/en/4.4/classes/class_packedscene.html)|
|Distance Above Floor|*Not included*|[float](https://docs.godotengine.org/en/stable/classes/class_float.html#float)|

As you can see there is one more variable in 3D variation of the component!


## Health2D

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

## Health3D

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

> From now on the scene you want to *instatiate* will be reffered as ***UI*** and the scene you want to *instantiate into* will be reffered as ***menu***.

To instantiate the *UI* to *menu* you just add the Scene spawner as a *****CHILD***** of *menu* and attach the *UI* to the [scene](#1-scene) variable. Then you add a refferance of the **SceneSpawner** in the *menu's* script like this: <code>@export var scene_spawner:SceneSpawner</code> and now by calling <code>scene_spawner.spawn(self)</code> you are spawning the *UI* to the menu.

> In that case inside <code>scene_spawner.spawn(...)</code> we added self because we wanted to add the UI to the script we were writing. We write inside the scene we want to *instantiate into*. If that scene is the **SceneSpawner's** parent we can leave it empty.

Now based of how your boolian variables *([spawn top level](#2-spawn-top-level) and [match transform top level](#3-match-transform-top-level))* are assigned there will be different instantiations!

- If both of them are ****true**** the *scene you want to spawn* will be spawned to the scene as a *****CHILD***** of the root node but it will have the [transform](#transform-the-global-position-and-rotation) of the node we have passed inside the spawn, *menu* in this case.
- If [spawn top level](#2-spawn-top-level) is only ****true**** the *scene you want to spawn* will be spawned to the scene as a *****CHILD***** of the root node but it will have the default [transform](#transform-the-global-position-and-rotation) (position: 0.0 and rotation: 0.0).
- If none of them are ****true**** the *scene you want to spawn* will be spawned to the scene as a *****CHILD***** of the node you passed in <code>*spawn*</code> and it will have the [transform](#transform-the-global-position-and-rotation) of the node we have passed inside the spawn, *menu* in this case.

## Advanced use

There are a lot of times we want to run a code to the scene we are adding, in this case you do not use: <code>scene_spawner.spawn(...)</code> but you use:

<code>
var ui:= scene_spawner.instantiate()<br>
#Here you run the code you want<br>
#Find where you want to instantiate for me is menu<br>
menu.add_child(ui)
</code>

# Glossary

###### death: when health reaches <code>0.0</code>.

###### transform: the global position and rotation.