# Performance

Keep idle inventory slots inexpensive and active contexts predictable.

## What runs while idle {#what-runs-while-idle}

- A newly created context stores configuration, component data, and lifetime connections. It creates no GUI.
- Bind() adds event connections for the target. It does not create a RenderStepped or Heartbeat connection per context.
- The manager connects one RenderStepped handler only while at least one context is visible, including pinned contexts.
- World bindings share event-driven Mouse.Target checks. Touch uses a single raycast for each world tap.

## Live updates and layout cost {#live-updates-and-layout-cost}

Setters preserve component Instances and connections. A setter may remeasure the rows in its own context, so layout cost is linear in that context’s component count. Changing data while hidden before first show only updates the data model. Prefer event-driven updates instead of calling setters every frame.

## Cleanup {#cleanup}

Destroy disconnects target and input ownership, cancels tracked callback tasks and tweens, removes component rows, destroys signals, and runs extension cleanup. A custom GUI returns to its original parent. The final context releases shared ScreenGui roots. Hidden surfaces are reused until Destroy.

## Practical limits

!!! note

    There is no automatic collision layout for multiple pinned panels. World hover is event-driven, so a moving object under a completely stationary camera/pointer may need your existing interaction system to open its context.

## Measure in your game {#measure-in-your-game}

Use Roblox’s MicroProfiler and memory tools with your actual content. Start with inactive contexts, then open one complex context and test a few pinned surfaces. Test mobile text wrapping, custom GUI dimensions, and touch hit targets at your game’s smallest supported viewport.
