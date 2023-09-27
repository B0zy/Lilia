
lia.xhair = lia.xhair or {}
lia.xhair.entIcon = {}

lia.xhair.entIgnore = {"func_physbox", "prop_dynamic"}

local w, h, aimVector, punchAngle, ft, screen, scaleFraction, distance, entity
local curGap = 0
local curAlpha = 0
local curIconAlpha = 0
local maxDistance = 1000 ^ 2
local crossSize = 4
local crossGap = 0
local colors = {color_black}
local filter = {}
local sw, sh = ScrW(), ScrH()
local lastIcon = ""

local function drawdot(pos, size, col)
    local color = col[2]
    surface.SetDrawColor(color.r, color.g, color.b, color.a)
    surface.DrawRect(pos[1] - size / 2 + 1, pos[2] - size / 2 + 1, size - 2, size - 2)
    local color = col[1]
    surface.SetDrawColor(0, 0, 0, col[2].a)
    surface.DrawOutlinedRect(pos[1] - size / 2, pos[2] - size / 2, size, size)
end

function GM:PostDrawHUD()
    local client = LocalPlayer()
    if not client:getChar() or not client:Alive() then return end
    local entity = Entity(client:getLocalVar("ragdoll", 0))
    if entity:IsValid() then return end
    local wep = client:GetActiveWeapon()
    if wep and wep:IsValid() and wep.HUDPaint then return end
    if hook.Run("ShouldDrawCrosshair") == false or g_ContextMenu:IsVisible() or IsValid(lia.gui.character) and lia.gui.character:IsVisible() then return end
    aimVector = client:EyeAngles()
    punchAngle = client:GetPunchAngle()
    w, h = ScrW(), ScrH()
    ft = FrameTime()
    filter = {client}
    local vehicle = client:GetVehicle()
    if vehicle and IsValid(vehicle) then
        aimVector = aimVector + vehicle:GetAngles()
        table.insert(filter, vehicle)
    end

    local data = {}
    data.start = client:GetShootPos()
    data.endpos = data.start + (aimVector + punchAngle):Forward() * 65535
    data.filter = filter
    local trace = util.TraceLine(data)
    entity = client:GetTracedEntity()
    distance = trace.StartPos:DistToSqr(trace.HitPos)
    scaleFraction = 1 - math.Clamp(distance / maxDistance, 0, .5)
    screen = trace.HitPos:ToScreen()
    crossSize = 4
    crossGap = 16
    curGap = Lerp(ft * 5, curGap, crossGap)
    colors[2] = Color(255, 255, 255, curAlpha, distance)
    local icon, adx, ady = hook.Run("GetCrosshairIcon", curAlpha, entity, wep, distance)
    local cx, cy = sw / 2, sh / 2
    if client:ShouldDrawLocalPlayer() then
        cx, cy = screen.x, screen.y
    end

    if icon then
        if icon ~= lastIcon then
            lastIcon = icon
        end

        curIconAlpha = Lerp(ft * 10, curIconAlpha, 255)
        curAlpha = Lerp(ft * 30, curAlpha, 0)
    else
        local showCross = not client.isWepRaised or client:isWepRaised()
        curIconAlpha = Lerp(ft * 30, curIconAlpha, 0)
        curAlpha = Lerp(ft * 10, curAlpha, showCross and 150 or 0)
    end

    curAlpha = hook.Run("GetCrosshairAlpha", curAlpha, entity) or curAlpha
    if curAlpha > 1 then
        drawdot({math.Round(cx), math.Round(cy)}, crossSize, colors)
        drawdot({math.Round(cx + curGap), math.Round(cy)}, crossSize, colors)
        drawdot({math.Round(cx - curGap), math.Round(cy)}, crossSize, colors)
        drawdot({math.Round(cx), math.Round(cy + curGap * .8)}, crossSize, colors)
        drawdot({math.Round(cx), math.Round(cy - curGap * .8)}, crossSize, colors)
    end

    if lastIcon then
        lia.util.drawText(lastIcon or "", cx + (adx or 0), cy + (ady or 0), ColorAlpha(color_white, curIconAlpha), 1, 1, "liaCrossIcons")
    end
end

function GM:GetCrosshairIcon(curAlpha, entity, weapon, distance)
    if table.Count(lia.menu.list) > 0 then return "", 0, ScreenScale(5) end
    if IsValid(wep) then
        if wep:GetNW2Bool("holdingObject", false) == true then return "" end
    end

    if IsValid(entity) and distance < 16384 then
        if not entity:IsPlayer() and not entity:IsNPC() then
            local class = entity:GetClass()
            if not table.HasValue(lia.xhair.entIgnore, class) then
                if class == "class C_BaseEntity" then return "" end
                if lia.xhair.entIcon[class] then return lia.xhair.entIcon[class] end
                if IsValid(wep) then
                    local class = wep:GetClass()
                    if entity.isDoor and entity:isDoor() then
                        if class == "lia_keys" then
                            local owner = entity.GetDTEntity(entity, 0)
                            local hey = entity:checkDoorAccess(wep.Owner)
                            if owner == LocalPlayer() or hey then return "" end
                        end

                        return ""
                    end

                    if class == "lia_hands" then return "" end
                end
            end
        end
    end
end
