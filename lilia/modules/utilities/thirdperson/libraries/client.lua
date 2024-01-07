﻿------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local view, traceData, traceData2, aimOrigin, crouchFactor, ft, curAng, diff, fm, sm
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local playerMeta = FindMetaTable("Player")
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local ThirdPerson = CreateClientConVar("tp_enabled", "0", true)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local ClassicThirdPerson = CreateClientConVar("tp_classic", "0", true)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local ThirdPersonVerticalView = CreateClientConVar("tp_vertical", 10, true)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local ThirdPersonHorizontalView = CreateClientConVar("tp_horizontal", 0, true)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local ThirdPersonViewDistance = CreateClientConVar("tp_distance", 50, true)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
crouchFactor = 0
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ThirdPersonCore:SetupQuickMenu(menu)
    if self.ThirdPersonEnabled then
        menu:addCheck(
            L"thirdpersonToggle",
            function(_, state)
                if state then
                    RunConsoleCommand("tp_enabled", "1")
                else
                    RunConsoleCommand("tp_enabled", "0")
                end
            end,
            ThirdPerson:GetBool()
        )

        menu:addCheck(
            L"thirdpersonClassic",
            function(_, state)
                if state then
                    RunConsoleCommand("tp_classic", "1")
                else
                    RunConsoleCommand("tp_classic", "0")
                end
            end,
            ClassicThirdPerson:GetBool()
        )

        menu:addButton(
            L"thirdpersonConfig",
            function()
                if lia.gui.tpconfig and lia.gui.tpconfig:IsVisible() then
                    lia.gui.tpconfig:Close()
                    lia.gui.tpconfig = nil
                end

                lia.gui.tpconfig = vgui.Create("ThirdPersonConfig")
            end
        )

        menu:addSpacer()
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ThirdPersonCore:CalcView(client)
    ft = FrameTime()
    if client:CanOverrideView() and LocalPlayer():GetViewEntity() == LocalPlayer() then
        if (client:OnGround() and client:KeyDown(IN_DUCK)) or client:Crouching() then
            crouchFactor = Lerp(ft * 5, crouchFactor, 1)
        else
            crouchFactor = Lerp(ft * 5, crouchFactor, 0)
        end

        curAng = owner.camAng or Angle(0, 0, 0)
        view = {}
        traceData = {}
        traceData.start = client:GetPos() + client:GetViewOffset() + curAng:Up() * math.Clamp(ThirdPersonVerticalView:GetInt(), 0, ThirdPersonCore.MaxValues.height) + curAng:Right() * math.Clamp(ThirdPersonHorizontalView:GetInt(), -ThirdPersonCore.MaxValues.horizontal, ThirdPersonCore.MaxValues.horizontal) - client:GetViewOffsetDucked() * .5 * crouchFactor
        traceData.endpos = traceData.start - curAng:Forward() * math.Clamp(ThirdPersonViewDistance:GetInt(), 0, ThirdPersonCore.MaxValues.distance)
        traceData.filter = client
        view.origin = util.TraceLine(traceData).HitPos
        aimOrigin = view.origin
        view.angles = curAng + client:GetViewPunchAngles()
        traceData2 = {}
        traceData2.start = aimOrigin
        traceData2.endpos = aimOrigin + curAng:Forward() * 65535
        traceData2.filter = client
        if ClassicThirdPerson:GetBool() or (owner.isWepRaised and owner:isWepRaised() or (owner:KeyDown(bit.bor(IN_FORWARD, IN_BACK, IN_MOVELEFT, IN_MOVERIGHT)) and owner:GetVelocity():Length() >= 10)) then client:SetEyeAngles((util.TraceLine(traceData2).HitPos - client:GetShootPos()):Angle()) end
        return view
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ThirdPersonCore:CreateMove(cmd)
    owner = LocalPlayer()
    if owner:CanOverrideView() and owner:GetMoveType() ~= MOVETYPE_NOCLIP and LocalPlayer():GetViewEntity() == LocalPlayer() then
        fm = cmd:GetForwardMove()
        sm = cmd:GetSideMove()
        diff = (owner:EyeAngles() - (owner.camAng or Angle(0, 0, 0)))[2] or 0
        diff = diff / 90
        cmd:SetForwardMove(fm + sm * diff)
        cmd:SetSideMove(sm + fm * diff)
        return false
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ThirdPersonCore:InputMouseApply(_, x, y, _)
    owner = LocalPlayer()
    if not owner.camAng then owner.camAng = Angle(0, 0, 0) end
    if owner:CanOverrideView() and LocalPlayer():GetViewEntity() == LocalPlayer() then
        owner.camAng.p = math.Clamp(math.NormalizeAngle(owner.camAng.p + y / 50), -85, 85)
        owner.camAng.y = math.NormalizeAngle(owner.camAng.y - x / 50)
        return true
    end
end

--------------------------------------------------------------------------------------------------------------------------
function ThirdPersonCore:PlayerButtonDown(_, button)
    if self.ThirdPersonEnabled and button == KEY_F4 and IsFirstTimePredicted() then
        if ThirdPerson:GetInt() == 1 then
            ThirdPerson:SetInt(0)
        else
            ThirdPerson:SetInt(1)
        end
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ThirdPersonCore:ShouldDrawLocalPlayer()
    if LocalPlayer():GetViewEntity() == LocalPlayer() and not IsValid(LocalPlayer():GetVehicle()) and LocalPlayer():CanOverrideView() then return true end
end

--------------------------------------------------------------------------------------------------------------------------
function playerMeta:CanOverrideView()
    local ragdoll = Entity(self:getLocalVar("ragdoll", 0))
    if IsValid(lia.gui.char) and lia.gui.char:IsVisible() then return false end
    return ThirdPerson:GetBool() and not IsValid(self:GetVehicle()) and self.ThirdPersonEnabled and IsValid(self) and self:getChar() and not IsValid(ragdoll) and LocalPlayer():Alive()
end

--------------------------------------------------------------------------------------------------------------------------
concommand.Add("tp_toggle", function() ThirdPerson:SetInt(ThirdPerson:GetInt() == 0 and 1 or 0) end)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
