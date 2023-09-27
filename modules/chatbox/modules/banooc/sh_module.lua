
local MODULE = MODULE

MODULE.oocBans = MODULE.oocBans or {}

MODULE.name = "OOC Bans"
MODULE.author = "STEAM_0:1:176123778"
MODULE.desc = "An OOC banlist."

lia.util.include("sv_module.lua")
lia.util.include("sh_chat.lua")

CAMI.RegisterPrivilege(
    {
        Name = "Lilia - Management - No OOC Cooldown",
        MinAccess = "admin",
        Description = "Allows access to use the OOC chat command without delay.",
    }
)
