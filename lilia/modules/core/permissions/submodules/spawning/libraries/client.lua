﻿function MODULE:SpawnMenuOpen()
    local client = LocalPlayer()
    if self.SpawnMenuLimit then return client:getChar():hasFlags("pet") or client:isStaffOnDuty() or CAMI.PlayerHasAccess(client, "Spawn Permissions - Can Spawn Props", nil) end
end
