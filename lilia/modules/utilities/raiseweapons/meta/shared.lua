﻿local MODULE = MODULE
local playerMeta = FindMetaTable("Player")
function playerMeta:isWepRaised()
    local weapon = self:GetActiveWeapon()
    local override = hook.Run("ShouldWeaponBeRaised", self, weapon)
    if override ~= nil then return override end
    if IsValid(weapon) then
        local weaponClass = weapon:GetClass()
        local weaponBase = weapon.Base
        if MODULE.PermaRaisedWeapons[weaponClass] or MODULE.PermaRaisedBases[weaponBase] or weapon.IsAlwaysRaised or weapon.AlwaysRaised then
            return true
        elseif weapon.IsAlwaysLowered or weapon.NeverRaised then
            return false
        end
    end

    if MODULE.WepAlwaysRaised then return true end
    return self:getNetVar("raised", false)
end
