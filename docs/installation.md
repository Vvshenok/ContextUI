# Installation

ContextUI comes as one ModuleScript with its internal modules already included.

## Install in Roblox Studio {#install-in-roblox-studio}

1. Download **[ContextUI.rbxm](https://github.com/Vvshenok/ContextUI/releases/latest/download/ContextUI.rbxm)** from the [latest release](https://github.com/Vvshenok/ContextUI/releases/latest).
2. In Studio, right-click **ReplicatedStorage → Insert from File** and select the download.
3. Keep the imported ModuleScript named **ContextUI**, including all its children.
4. Require it from a **LocalScript**:

```lua
local ContextUI = require(game.ReplicatedStorage.ContextUI)
```

Continue with [your first context](getting-started.md). You can move the module elsewhere if you update the require path; the library's internal paths are relative.

## Dependencies and updates {#dependencies-and-updates}

There are no external runtime dependencies. Signal and cleanup helpers are included. To update, replace the complete ModuleScript and its children. ContextUI runs on the client; gameplay changes requested by its buttons still belong to your server.
