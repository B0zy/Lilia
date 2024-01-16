﻿function AdvDupe2Compatibility:CanTool(client, _, tool)
    local privilege = "Staff Permissions - Access Tool " .. tool:gsub("^%l", string.upper)
    local entity = client:GetTracedEntity()
    local validEntity = IsValid(entity)
    if tool == "advdupe2" and IsValid(client) and (client:getChar():hasFlags("t") or client:isStaffOnDuty()) and CAMI.PlayerHasAccess(client, privilege, nil) then
        if (table.HasValue(PermissionCore.DuplicatorBlackList, entity) or entity.NoDuplicate) and validEntity then return false end
        if client.AdvDupe2 and client.AdvDupe2.Entities then
            for _, v in pairs(client.AdvDupe2.Entities) do
                if v.ModelScale > 10 then
                    client:notify("A model within this duplication exceeds the size limit!")
                    print("[Server Warning] Potential server crash using dupes attempt by player: " .. client:Nick() .. " (" .. client:SteamID() .. ")")
                    return false
                end

                v.ModelScale = 1
            end
        end
        return true
    end
end

function AdvDupe2Compatibility:PlayerSpawnProp(client)
    if client.AdvDupe2 and client.AdvDupe2.Entities then return true end
end

function AdvDupe2Compatibility:PlayerSpawnObject(client, _, _)
    if client.AdvDupe2 and client.AdvDupe2.Entities then return true end
end

function AdvDupe2Compatibility:PlayerSpawnRagdoll(client)
    if client.AdvDupe2 and client.AdvDupe2.Entities then return true end
end
