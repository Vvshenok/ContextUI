# Advanced Configuration

Tune the behavior without adding setup modules to your game.

## Context options {#context-options}

Pass a configuration table as the second argument to new(). Numeric dimensions and durations must be finite and nonnegative; width/height have minimum supported bounds. Configuration is copied per context.

| Option | Default | Meaning |
| --- | --- | --- |
| MaxWidth | 320 | Maximum outer width in pixels. |
| MinWidth | 0 | Optional minimum outer width, constrained by viewport. |
| MaxHeight | 480 | Maximum outer height; overflow scrolls. |
| Offset | Vector2.new(14, 16) | Pointer/anchor offset in screen pixels. |
| EdgePadding | 8 | Padding inside the usable viewport. |
| CloseDelay | 0.18 | Seconds before closing after leaving. |
| TransitionGrace | 0.6 | Maximum seconds the safe corridor can extend a transition. |
| SafePadding | 10 | Pixels added to the corridor edge. |
| DockThreshold | 3 | Cumulative approach distance in pixels required to dock. |
| DisplayOrder | 50 | Shared ScreenGui layer; screens are grouped by this value. |
| WorldRayLength | 2048 | Maximum touch world-hit distance in studs. |
| Interactive | nil | Optional advanced override; nil uses automatic detection. |
| Theme | Default | ThemeName string, a preset table, or partial ThemeOverrides. |
| Animation | default animation | Partial AnimationConfig table. |

## Extensions {#extensions}

Use() installs a named extension once per context. Return a cleanup function to release resources when the context is destroyed. Use public methods inside extensions; internal fields are not stable API.

```lua
context:Use({
    Name = "StateLogging",
    Install = function(view)
        local connection = view.StateChanged:Connect(function(state)
            print(state)
        end)
        return function() connection:Disconnect() end
    end,
})
```

## State and surface access {#state-and-surface-access}

GetState() returns Hidden, Following, Docked, Pinned, or Destroyed. StateChanged fires synchronously on transitions. Keep listeners short and non-yielding. GetSurface() returns nil before the first Show, then the owned CanvasGroup. Reading it for integration is supported; replacing its descendants or layout can invalidate renderer assumptions.

## Application boundaries {#application-boundaries}

ContextUI owns presentation and input connections. It does not install remotes, game services, team permissions, tool permissions, or server-side actions. Connect it to those existing systems explicitly.
