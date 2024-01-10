﻿function SimfphysCompatibility:simfphysUse(entity, client)
    if simfphys.IsCar(entity) and self.TimeToEnterVehicle > 0 and not (entity.IsBeingEntered or entity.IsLocked) then
        entity.IsBeingEntered = true
        client:setAction("Entering Vehicle...", self.TimeToEnterVehicle)
        client:doStaredAction(
            entity,
            function()
                entity.IsBeingEntered = false
                entity:SetPassenger(client)
            end,
            self.TimeToEnterVehicle,
            function()
                if IsValid(entity) then
                    entity.IsBeingEntered = false
                    client:setAction()
                end

                if IsValid(client) then client:setAction() end
            end
        )
    end
    return self.CarEntryDelayEnabled
end

function SimfphysCompatibility:OnEntityCreated(entity)
    if simfphys.IsCar(entity) then
        entity.PhysicsCollideBack = entity.PhysicsCollide
        entity.PhysicsCollide = function(vehicle, data, physobj)
            if not self.DamageInCars then
                entity:PhysicsCollideBack(data, physobj)
                return
            end

            if data.DeltaTime < 0.2 then return end
            local speed = data.Speed
            local mass = 1
            local hitEnt = data.HitEntity
            if not hitEnt:IsWorld() then mass = math.Clamp(data.HitObject:GetMass() / physobj:GetMass(), 0, 1) end
            local dmg = speed * speed * mass / 5000
            if not dmg or dmg < 1 then return end
            local pos = data.HitPos
            if simfphys.IsCar(hitEnt) then
                local vel = data.OurOldVelocity
                local tvel = data.TheirOldVelocity
                local dif = data.OurNewVelocity - tvel
                local dot = -dif:Dot(tvel:GetNormalized())
                local fwd = vehicle:GetForward()
                local lpos = vehicle:WorldToLocal(pos)
                local side = 1 - math.abs(fwd:Dot((pos - vehicle:GetPos()):GetNormalized()))
                dmg = dmg * math.Clamp(dot / speed, 0.1, 0.9) * damageMul
                print("Dmg:", dmg, "\nSpeed:", speed, "\nVel:", vel, "\nTVel:", tvel, "\nDif:", dif, "\nDot:", dot / speed, "\nLPos:", lpos, "\nSideMult:", side)
            end

            if dmg >= 100 then
                sound.Play(Sound("MetalVehicle.ImpactHard"), pos)
            elseif dmg >= 10 then
                sound.Play(Sound("MetalVehicle.ImpactSoft"), pos)
            end

            local dmginfo = DamageInfo()
            dmginfo:SetDamage(dmg)
            dmginfo:SetAttacker(hitEnt)
            dmginfo:SetInflictor(vehicle)
            dmginfo:SetDamageType(DMG_CRUSH)
            dmginfo:SetDamagePosition(pos)
            local force = Vector((vehicle:GetPos() - pos):GetNormalized() * dmg * physobj:GetMass() * 100)
            dmginfo:SetDamageForce(force)
            vehicle:TakeDamageInfo(dmginfo)
        end
    end
end

function SimfphysCompatibility:EntityTakeDamage(entity, dmgInfo)
    local damageType = dmgInfo:GetDamageType()
    if self.DamageInCars and entity:IsVehicle() and table.HasValue(self.ValidCarDamages, damageType) then
        local client = entity:GetDriver()
        if IsValid(client) then
            local hitPos = dmgInfo:GetDamagePosition()
            local clientPos = client:GetPos()
            local thresholdDistance = 53
            if hitPos:Distance(clientPos) <= thresholdDistance then
                local newHealth = client:Health() - (dmgInfo:GetDamage() * 0.3)
                if newHealth > 0 then
                    client:SetHealth(newHealth)
                else
                    client:Kill()
                end
            end
        end
    end
end

function SimfphysCompatibility:isSuitableForTrunk(ent)
    if IsValid(ent) and simfphys.IsCar(ent) then return true end
end

function SimfphysCompatibility:CheckValidSit(client, _)
    local entity = client:GetTracedEntity()
    if simfphys.IsCar(entity) then return false end
end
