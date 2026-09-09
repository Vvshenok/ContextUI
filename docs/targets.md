# Targets

Attach the same context to interface elements or objects in the world.

## Supported targets {#supported-targets}

| Option | Behavior |
| --- | --- |
| GuiObject | Frames, labels, buttons, inventory slots, and other GUI objects. Mouse enter/leave, touch, and selection connect on Bind(). |
| BasePart | A queryable world part. Uses the local Roblox Mouse.Target. |
| Model | Hover any descendant part. A more specific part binding takes precedence over its ancestor model. |
| Attachment | The containing BasePart is the hit target. The attachment is not given an invented invisible hitbox. |
| nil | Manual context. Call Show(), Hide(), or Pin() yourself. |

## World objects {#world-objects}

```lua
local ContextUI = require(game.ReplicatedStorage.ContextUI)
ContextUI.new(workspace:WaitForChild("Shop"))
    :SetTitle("Shop")
    :AddButton("Open", function(context)
        print("Connect this to your shop interface")
        context:Hide()
    end)
    :Bind()
```

!!! note

    Pass a BasePart, Model, or Attachment. A Player instance is not a target; attach to its character Model or to its UI entry.

## How world input works {#how-world-input-works}

Desktop hit detection uses Mouse.Target on mouse and camera movement, with no library raycast loop. Touch performs one raycast per world tap, up to WorldRayLength. Parts must participate in Roblox hit testing. Fully stationary input and camera do not continuously discover moving objects beneath the cursor; use explicit Show/Hide from your existing interaction system when that behavior is needed.

## Change or remove a target {#change-or-remove-a-target}

SetTarget() disconnects the old binding, hides the surface, and rebinds the new target if the context was bound. Bind() is idempotent. Two contexts cannot bind the same exact hit target; this includes attachments sharing one part.

```lua
context:SetTarget(otherButton)
context:Unbind()
context:Bind()
```
