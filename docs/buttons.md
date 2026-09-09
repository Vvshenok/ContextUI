# Buttons

Add actions without making the panel difficult to reach.

## Automatic interactivity {#automatic-interactivity}

A visible button, button group, or interactive custom component enables docking. The panel initially follows the pointer. Movement toward the surface docks it; leaving the target also docks interactive panels immediately. A bounded safe corridor and close delay give the pointer time to reach the surface.

```lua
context:AddButton("Equip", function(view)
    print("Equip requested")
    view:Hide()
end, { Id = "Equip", KeyCode = Enum.KeyCode.E })
```

## Button configuration {#button-configuration}

| Option | Behavior |
| --- | --- |
| Id / ExpandedOnly | Standard component options. |
| Disabled: boolean? | Prevents activation and selection. Defaults to false. |
| KeyCode: Enum.KeyCode? | Activates while this context is focused and visible. Ignored during text entry or processed game input. |
| Callback(context) | Receives the context. Runs in a tracked task; errors are isolated and reported. |

## Button groups {#button-groups}

Buttons keep their natural width and wrap to another line when needed. Disabling a group disables every button in the group.

```lua
context:AddButtonGroup({
    { Text = "Inspect", Callback = function(view) view:Expand() end },
    { Text = "Compare", Callback = function(view) view:Pin() end },
}, { Id = "Actions" })

context:SetButtonEnabled("Actions", false)
```

## Mouse, touch, and gamepad {#mouse-touch-and-gamepad}

GuiButtons use Activated. Touch opens a docked panel; tapping away begins the close delay. Selecting a target with a gamepad opens its panel and transfers selection to its first available built-in action. Escape or ButtonB dismisses the focused context when Roblox has not already processed the input. Manual/world gamepad interaction can use your own selection or proximity system to call Show().

## Application actions {#application-actions}

Keep authority on your server. A UI callback can request an equip, purchase, arrest, or other game action, but the server must validate it. ContextUI never grants tools, changes teams, charges currency, or changes game permissions.

## Advanced override {#advanced-override}

SetInteractive(true) forces docking behavior. SetInteractive(false) forces passive behavior even with buttons. SetInteractive(nil) restores automatic detection. The false override can make buttons difficult to reach, so use it only when another system controls positioning.
