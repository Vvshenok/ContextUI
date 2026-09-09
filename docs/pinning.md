# Pinning

Keep an inspector open while the player looks elsewhere.

## Pin and unpin {#pin-and-unpin}

Pin() opens a hidden context if needed, stops following, and keeps it open even outside the target and surface. It remains able to receive input. Unpin() restores docking for interactive content or following for passive content.

```lua
context:AddButton("Pin", function(view) view:Pin() end)
context:AddButton("Unpin", function(view) view:Unpin() end)
context:AddButton("Close", function(view) view:Hide() end)
```

## Multiple contexts {#multiple-contexts}

The manager normally shows one unpinned context. Opening another hides the previous unpinned surface. Pinned contexts stay open. The most recently opened context receives keyboard shortcuts. Clicking a pinned panel or selecting one of its controls focuses it again. Pinning keeps the current screen position; ContextUI does not automatically arrange or drag pinned surfaces.

## Closing a pin {#closing-a-pin}

Hide(), target destruction, and Destroy() can still close a pinned context. Escape and ButtonB dismiss the focused context when the input has not already been processed by Roblox. Unpinning while outside begins the close delay. Pinning prevents automatic pointer-leave dismissal; it does not prevent explicit dismissal.
