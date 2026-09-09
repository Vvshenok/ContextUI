# Animations

Short transitions that support the interaction.

## Animation settings {#animation-settings}

```lua
ContextUI.new(button, {
    Animation = {
        ShowDuration = 0.14,
        HideDuration = 0.10,
        ResizeDuration = 0.16,
        FollowSpeed = 24,
        ReducedMotion = false,
    },
})
```

| Option | Behavior |
| --- | --- |
| ShowDuration | Fade-in duration in seconds. |
| HideDuration | Fade-out duration in seconds. |
| ResizeDuration | Size transition duration for content and expansion changes. |
| FollowSpeed | Frame-rate-independent smoothing rate. Larger values catch up faster; must be positive. |
| ReducedMotion | Makes fades, resizes, and following immediate. Defaults to false. |

## Docking feels stable {#docking-feels-stable}

The surface follows a smoothed position. Once approach is detected, it keeps its current rendered location. It does not chase the cursor across the buttons. Viewport changes can still move a docked or pinned panel back inside the screen.

## Animation ownership {#animation-ownership}

Replacing an animation cancels and destroys the previous tween in that channel. Hide followed immediately by Show cancels the old fade-out. Destroy cancels all owned tweens and disconnects completion handlers. There are no perpetual shine or idle animation tasks.

## Reduced motion {#reduced-motion}

Pass ReducedMotion from your game’s accessibility settings. ContextUI does not read or change private player settings.

```lua
context = ContextUI.new(button, { Animation = { ReducedMotion = true } })
```
