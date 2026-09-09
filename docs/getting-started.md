# Getting Started

Create a ContextUI and attach it to something you want players to inspect.

## Your first context {#your-first-context}

Import the ContextUI module into ReplicatedStorage. Add a LocalScript under a TextButton, paste this example, and press Play. Hover or tap the button to see the context.

```lua
local ContextUI = require(game.ReplicatedStorage.ContextUI)

ContextUI.new(script.Parent)
    :SetTitle("Shop")
    :SetDescription("Open the store")
    :Bind()
```

## Three ideas to remember {#three-ideas-to-remember}

- new(target) creates a context without creating a surface.
- Chain methods to add content. Bind() connects the target to input.
- Keep the returned context if you need to update it or call Destroy().

## Add an action {#add-an-action}

Adding a button makes the surface interactive automatically. As the pointer approaches the panel, it docks so the action remains reachable.

```lua
local context = ContextUI.new(button)
    :SetTitle("Legendary Sword")
    :AddStat("Damage", 75)
    :AddButton("Inspect", function(view)
        view:SetDescription("A well-balanced blade.")
    end)
    :Bind()
```

## Own the lifetime {#own-the-lifetime}

Destroy contexts when their feature is removed. Target destruction also destroys its context automatically. Hide() closes a surface while keeping it ready to open again.

```lua
context:Destroy()
```
