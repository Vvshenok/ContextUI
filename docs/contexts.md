# Contexts

A context owns its configuration, component data, input binding, and rendered panel. Create it on the client and keep a reference while your feature uses it.

## Create and bind

```lua
local ContextUI = require(game.ReplicatedStorage.ContextUI)
local context = ContextUI.new(script.Parent)
    :SetTitle("Open map")
    :Bind()
```

`new()` stores content without allocating a GUI surface. `Bind()` connects the target's supported input events. The first hover, tap, selection, or explicit `Show()` creates the panel; later openings reuse it.

## Targets and manual contexts

Pass a GUI object, part, model, or attachment. See [Targets](targets.md) for hit-testing behavior. Omit the target when your own interface decides when to show the panel:

```lua
local context = ContextUI.new(nil, { Theme = "Soft" })
    :SetTitle("Round results")
    :AddStat("Score", 1250)

context:Show(Vector2.new(240, 160)):Pin()
```

`SetTarget(otherTarget)` moves an existing binding. `SetTarget(nil)` switches to manual control. It also hides the old panel.

## Visibility and ownership

`Hide()` closes a panel while keeping its content. `Unbind()` disconnects target input and hides the panel. `Destroy()` releases the context completely and is safe to call again.

Destroying a target automatically destroys its context. Hiding the target itself or removing it from the data model hides the panel. When hiding an ancestor screen or container, call `Hide()` or `Unbind()` from that feature's lifecycle.

See [Cleanup and lifecycle](lifecycle.md) for custom content, tasks, and extension ownership.
