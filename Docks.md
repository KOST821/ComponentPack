# How to use

- <img width="16" height="16" alt="gravity" src="/Gravity/gravity.svg"/> [Gravity](#gravity)
- <img width="16" height="16" alt="drag_and_drop" src="/DragAndDrop/chess_pawn.svg"/> [Drag and Drop](#drag-and-drop)

<br> <br>

# Gravity

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

## Advanced Settings

The <code>get_gravity(...)</code> function accepts optional parameters to fine-tune how your Node falls.

### Max Falling Speed (Terminal Velocity)

In the example to prevent your character from falling infinitely fast, provide a **maximum falling speed** as the third argument. If we want the max falling speed to be 450.0, we edit the line like this:

    if not is_on_floor():
        velocity.y = gravity.get_gravity(delta, velocity.y)
And make it like this:

    if not is_on_floor():
        velocity.y = gravity.get_gravity(delta, velocity.y, 450.0)

### Descending Gravity Factor (Fall Multiplier)

To make jumps feel less "floaty", you can apply a multiplier to the gravity only when the entity is falling downwards. Values above 1.0 create heavier, snappier falls (commonly seen in platformers).

    if not is_on_floor():
        velocity.y = gravity.get_gravity(delta, velocity.y, 450.0, 1.5)

Keep in mind that if you want to have **descending gravity factor** but not a [**maximum falling speed**](#max-falling-speed-terminal-velocity) you just add <code> 0.0 </code> to the 3rd value (**maximum falling speed**).

<br>

# Drag And Drop

This component is used to add a drag and drop feature to an [*CollisionObject2D*](https://docs.godotengine.org/en/stable/classes/class_collisionobject2d.html).

## Use

If we had a [*CharacterBody2D*](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html) with no scripts, and as children a **collision shape** and a **drag and drop** when you "grab" the [*CharacterBody2D*](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html) inside the collision shape you can move it! To work you must look at those 6 things:

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

The Node who uses the component, must be a [CollisionObject2D](https://docs.godotengine.org/en/stable/classes/class_collisionobject2d.html) to receive mouse events. If empty the parent will be placed, assuming the parent is [CollisionObject2D](https://docs.godotengine.org/en/stable/classes/class_collisionobject2d.html). If empty at last, the game will give you an <font color="#eb4634"> ***Error***</font>.

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

# Health
*****TO BE WRITEN*****