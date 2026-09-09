# Stats

Keep values current without destroying and recreating your interface.

## Update a stat {#update-a-stat}

The label becomes the ID unless you specify another ID. SetStat changes the existing row. Layout is remeasured because a longer value may need more space.

```lua
context:AddStat("Ammo", "30/30")
context:SetStat("Ammo", "15/30")

context:AddStat("Damage", 75, { Id = "PrimaryDamage" })
context:SetStat("PrimaryDamage", 80)
```

## Update progress {#update-progress}

Progress values are fractions, clamped between 0 and 1. NaN is rejected. The existing fill changes width in place.

```lua
context:AddProgress("Durability", 0.9)
context:SetProgress("Durability", 0.65)
```

## Use attributes you already have {#use-attributes-you-already-have}

Use an extension to own attribute connections. The WeaponStats example connects Ammo, Capacity, and Durability updates and disconnects them when the context is destroyed.

```lua
context:Use({
    Name = "AmmoAttribute",
    Install = function(view)
        local function update()
            view:SetStat("Ammo", tostring(weapon:GetAttribute("Ammo") or 0))
        end
        local connection = weapon:GetAttributeChangedSignal("Ammo"):Connect(update)
        update()
        return function() connection:Disconnect() end
    end,
})
```

## Missing or duplicate IDs {#missing-or-duplicate-ids}

SetStat and SetProgress raise a descriptive error if the ID is missing or has the wrong component kind. Adding a duplicate ID raises an error. Remove(id) is safe to call when the ID is already absent.
