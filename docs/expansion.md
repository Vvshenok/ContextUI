# Expansion

Reveal deeper information in the same panel.

## Create collapsed and expanded content {#create-collapsed-and-expanded-content}

Mark details as ExpandedOnly, then add the More control with SetExpandable(true). Existing rows remain allocated when collapsed; expanding reveals them and animates the outer size.

```lua
ContextUI.new(slot)
    :SetTitle("Sword")
    :AddStat("Damage", 75)
    :AddText("Forged for long journeys.", { ExpandedOnly = true })
    :AddStat("Speed", 1.4, { ExpandedOnly = true })
    :AddProgress("Durability", 0.9, { ExpandedOnly = true })
    :SetExpandable(true)
    :Bind()
```

## Control expansion yourself {#control-expansion-yourself}

Expand(), Collapse(), and ToggleExpanded() are chainable. IsExpanded() returns a boolean. You do not need the built-in control if another action handles expansion.

```lua
context:Expand()
context:Collapse()
context.ExpandedChanged:Connect(function(expanded)
    print("Expanded:", expanded)
end)
```

## Labels and overflow {#labels-and-overflow}

SetExpandable(true, "Details") changes the collapsed label; the expanded label is Less. SetExpandable(false) removes the control and collapses the context. Content that exceeds MaxHeight scrolls. Hidden expanded-only buttons do not enable interactivity until revealed, but the More button itself does.
