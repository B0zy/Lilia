﻿local MODULE = MODULE

util.AddNetworkString("IAmHackingOwO")

for _, v in pairs(MODULE.KnownExploits) do
    net.Receive(tostring(v), function(_, client)
        client.nextExploitNotify = client.nextExploitNotify or 0
        if client.nextExploitNotify > CurTime() then return end
        client.nextExploitNotify = CurTime() + 2
        for _, p in pairs(player.GetAll()) do
            if p:isStaffOnDuty() then p:notify(client:Name() .. " (" .. client:SteamID() .. (v and ") may be attempting to crash the server!" or ") may be attempting to run exploits!")) end
        end
    end)
end

net.Receive("IAmHackingOwO", function(_, client) MODULE:ApplyPunishment(client, "Hacking", true, true, 0) end)