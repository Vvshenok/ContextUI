# Cleanup and lifecycle

Keep the context for as long as its feature needs it. Call `Destroy()` when that feature is removed:

```lua
context:Destroy()
```

Destruction releases target bindings, the rendered surface, tweens, signals, tracked callback tasks, and extension cleanup. Destroying the target does the same. Repeated `Destroy()`, `Hide()`, and `Unbind()` calls are safe.

## Hiding is reusable

`Hide()` closes the surface while retaining its rows. `Unbind()` also disconnects automatic target input. Neither releases the context's component data; use `Destroy()` when finished.

## Custom GUI belongs to its caller

`AddCustom()` temporarily reparents the original GUI, preserving its connections. Removing that row or destroying the context restores its parent, position, size, and anchor. If the original parent was destroyed, the GUI is left unparented. Do not give the same GUI to multiple contexts at once.

Destroy the caller-owned GUI yourself when you no longer need it. ContextUI does not restyle its descendants.

## Own external connections with an extension

```lua
context:Use({
    Name = "AmmoAttribute",
    Install = function(view)
        local function refresh()
            view:SetStat("Ammo", tostring(weapon:GetAttribute("Ammo") or 0))
        end
        local connection = weapon:GetAttributeChangedSignal("Ammo"):Connect(refresh)
        refresh()
        return function()
            connection:Disconnect()
        end
    end,
})
```

Add the `Ammo` stat before installing this extension. Extension names must be unique within a context.

Button callbacks run in tracked tasks. Tasks you create outside those callbacks remain your responsibility. Signal listeners run synchronously; keep them short and non-yielding.
