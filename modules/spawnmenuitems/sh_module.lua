
local MODULE = MODULE

MODULE.name = "Spawn Menu Items"
MODULE.desc = "Adds a tab to the spawn menu for spawning items."
MODULE.author = "STEAM_0:1:176123778"

lia.config.cooldown = 0.5
lia.config.CanSpawnMenuItems = {
    ["superadmin"] = true,
    ["admin"] = false,
    ["user"] = false,
}

lia.util.include("cl_module.lua")
lia.util.include("sv_module.lua")
