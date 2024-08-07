﻿local MODULE = MODULE
local PANEL = {}
local StaffCount = 0
local StaffOnDutyCount = 0
local paintFunctions = {}
paintFunctions[0] = function(_, w, h)
    surface.SetDrawColor(0, 0, 0, 50)
    surface.DrawRect(0, 0, w, h)
end

paintFunctions[1] = function() end
function PANEL:Init()
    if IsValid(lia.gui.score) then lia.gui.score:Remove() end
    lia.gui.score = self
    self:SetSize(ScrW() * MODULE.sbWidth, ScrH() * MODULE.sbHeight)
    if MODULE.DisplayServerName then
        self.serverName = self:Add("DLabel")
        self.serverName:SetText(GetHostName())
        self.serverName:SetFont("liaMediumFont")
        self.serverName:SetContentAlignment(5)
        self.serverName:SetTextColor(color_white)
        self.serverName:SetExpensiveShadow(1, color_black)
        self.serverName:Dock(TOP)
        self.serverName:SizeToContentsY()
        self.serverName.Paint = function(_, w, h)
            surface.SetDrawColor(0, 0, 0, 150)
            surface.DrawRect(0, 0, w, h)
        end
    end

    self.scroll = self:Add("DScrollPanel")
    self.scroll:Dock(FILL)
    self.scroll:DockMargin(1, 0, 1, 0)
    self.scroll.VBar:SetWide(0)
    self.layout = self.scroll:Add("DListLayout")
    self.layout:Dock(TOP)
    self.teams = {}
    self.slots = {}
    self.i = {}
    self:Center()
    for k, v in ipairs(lia.faction.indices) do
        local color = team.GetColor(k)
        local r, g, b = color.r, color.g, color.b
        local list = self.layout:Add("DListLayout")
        list:Dock(TOP)
        list:SetTall(28)
        list.Think = function(this)
            for _, v2 in ipairs(lia.faction.getPlayers(k)) do
                if hook.Run("ShouldShowPlayerOnScoreboard", v2) == false then continue end
                if not IsValid(v2.liaScoreSlot) or v2.liaScoreSlot:GetParent() ~= this then
                    if IsValid(v2.liaScoreSlot) then
                        v2.liaScoreSlot:SetParent(this)
                    else
                        self:addPlayer(v2, this)
                    end
                end
            end
        end

        local header = list:Add("DLabel")
        local icon_material = lia.faction.indices[v.index].logo
        local hasLogo = false
        if icon_material and icon_material ~= "" then
            local icon = header:Add("DImage")
            icon:Dock(RIGHT)
            icon:SetWide(56)
            icon:SetMaterial(Material(icon_material))
            hasLogo = true
        end

        header:Dock(TOP)
        header:SetText(L(v.name))
        header:SetTextInset(3, 0)
        header:SetFont(hasLogo and "liaBigFont" or "liaMediumFont")
        header:SetTextColor(color_white)
        header:SetContentAlignment(5)
        header:SetExpensiveShadow(1, color_black)
        header:SetTall(hasLogo and 64 or 28)
        header.Paint = function(_, w, h)
            surface.SetDrawColor(r, g, b, 20)
            surface.DrawRect(0, 0, w, h)
        end

        self.teams[k] = list
    end

    self.staff1 = self:Add("DLabel")
    self.staff1:SetText("Staff Online: 0")
    self.staff1:SetFont("liaMediumFont")
    self.staff1:SetContentAlignment(5)
    self.staff1:SetTextColor(color_white)
    self.staff1:SetExpensiveShadow(1, color_black)
    self.staff1:Dock(BOTTOM)
    self.staff1:SizeToContentsY()
    self.staff1.Paint = function(_, w, h)
        surface.SetDrawColor(0, 0, 0, 150)
        surface.DrawRect(0, 0, w, h)
    end
end

function PANEL:UpdateStaff()
    StaffCount = 0
    StaffOnDutyCount = 0
    for _, target in pairs(player.GetAll()) do
        if target:isStaff() then StaffCount = StaffCount + 1 end
        if target:isStaffOnDuty() then StaffOnDutyCount = StaffOnDutyCount + 1 end
    end

    self.staff1:SetText("Players Online: " .. player.GetCount() .. " | Staff On Duty: " .. StaffOnDutyCount .. " | Staff Online: " .. StaffCount)
end

function PANEL:Think()
    local client = LocalPlayer()
    if (self.nextUpdate or 0) < CurTime() then
        local visible, amount
        for k, v in ipairs(self.teams) do
            visible, amount = v:IsVisible(), lia.faction.getPlayerCount(k)
            if k == FACTION_STAFF then
                v:SetVisible(not MODULE.ShowStaff and client:isStaffOnDuty() or amount > 0)
            else
                v:SetVisible(visible and amount > 0)
            end

            self.layout:InvalidateLayout()
        end

        for _, v in pairs(self.slots) do
            if IsValid(v) then v:update() end
        end

        if input.IsKeyDown(KEY_Z) then self:Init() end
        self.nextUpdate = CurTime() + 0.1
        self:UpdateStaff()
    end
end

function PANEL:addPlayer(ply, parent)
    local client = LocalPlayer()
    if not ply:getChar() or not IsValid(parent) then return end
    local slot = parent:Add("DPanel")
    slot:Dock(TOP)
    slot:SetTall(64)
    slot:DockMargin(0, 0, 0, 1)
    slot.character = ply:getChar()
    ply.liaScoreSlot = slot
    slot.model = slot:Add("liaSpawnIcon")
    slot.model:SetModel(ply:GetModel(), ply:GetSkin())
    slot.model:SetSize(64, 64)
    slot.model.DoClick = function()
        local menu = DermaMenu()
        local options = {}
        hook.Run("ShowPlayerOptions", ply, options)
        if table.Count(options) > 0 then
            for k, v in SortedPairs(options) do
                menu:AddOption(L(k), v[2]):SetImage(v[1])
            end
        end

        menu:Open()
        RegisterDermaMenuForClose(menu)
    end

    slot.model:SetTooltip(L("sbOptions", ply:Name()))
    timer.Simple(0, function()
        if not IsValid(slot) then return end
        local entity = slot.model.Entity
        if IsValid(entity) then
            for _, v in ipairs(ply:GetBodyGroups()) do
                entity:SetBodygroup(v.id, ply:GetBodygroup(v.id))
            end

            for k, _ in ipairs(ply:GetMaterials()) do
                entity:SetSubMaterial(k - 1, ply:GetSubMaterial(k - 1))
            end
        end
    end)

    slot.name = slot:Add("DLabel")
    slot.name:Dock(TOP)
    slot.name:DockMargin(65, 0, 48, 0)
    slot.name:SetTall(18)
    slot.name:SetFont("liaGenericFont")
    slot.name:SetTextColor(color_white)
    slot.name:SetExpensiveShadow(1, color_black)
    slot.ping = slot:Add("DLabel")
    slot.ping:SetPos(self:GetWide() - 48, 0)
    slot.ping:SetSize(48, 64)
    slot.ping:SetText("0")
    slot.ping.Think = function(this) if IsValid(ply) then this:SetText(ply:Ping()) end end
    slot.ping:SetFont("liaGenericFont")
    slot.ping:SetContentAlignment(6)
    slot.ping:SetTextColor(color_white)
    slot.ping:SetTextInset(16, 0)
    slot.ping:SetExpensiveShadow(1, color_black)
    slot.ping.Think = function(this)
        if IsValid(ply) then
            local ping = ply:Ping()
            local text = this:GetText()
            if text ~= ping then
                this:SetText(ping)
                this:SizeToContentsX()
                this:SetPos(self:GetWide() - (24 + (string.len(this:GetText()) * 4)))
            end
        end
    end

    slot.desc = slot:Add("DLabel")
    slot.desc:Dock(FILL)
    slot.desc:DockMargin(65, 0, 48, 0)
    slot.desc:SetWrap(true)
    slot.desc:SetContentAlignment(7)
    slot.desc:SetTextColor(color_white)
    slot.desc:SetExpensiveShadow(1, Color(0, 0, 0, 100))
    slot.desc:SetFont("liaSmallFont")
    local oldTeam = ply:Team()
    function slot:update()
        if not IsValid(ply) or not ply:getChar() or not self.character or self.character ~= ply:getChar() or oldTeam ~= ply:Team() then
            self:Remove()
            local i = 0
            for _, v in ipairs(parent:GetChildren()) do
                if IsValid(v.model) and v ~= self then
                    i = i + 1
                    v.Paint = paintFunctions[i % 2]
                end
            end
            return
        end

        local overrideName = hook.Run("ShouldAllowScoreboardOverride", ply, "name") and hook.Run("GetDisplayedName", ply) or ply:getChar():getName()
        local name = overrideName or ply:Name()
        name = name:gsub("#", "\226\128\139#")
        local model = ply:GetModel()
        local skin = ply:GetSkin()
        local desc = hook.Run("ShouldAllowScoreboardOverride", ply, "desc") and hook.Run("GetDisplayedDescription", ply, false) or ply:getChar():getDesc()
        desc = desc:gsub("#", "\226\128\139#")
        self.model:setHidden(hook.Run("ShouldAllowScoreboardOverride", ply, "model"))
        if self.lastName ~= name then
            self.name:SetText(name)
            self.lastName = name
        end

        local entity = self.model.Entity
        if not IsValid(entity) then return end
        if self.lastDesc ~= desc then
            self.desc:SetText(desc)
            self.lastDesc = desc
        end

        if self.lastModel ~= model or self.lastSkin ~= skin then
            self.model:SetModel(ply:GetModel(), ply:GetSkin())
            if client:HasPrivilege("Staff Permissions - Can Access Scoreboard Info Out Of Staff") or (client:HasPrivilege("Staff Permissions - Can Access Scoreboard Admin Options") and client:isStaffOnDuty()) then
                self.model:SetTooltip(L("sbOptions", ply:Name()))
            else
                self.model:SetTooltip("You do not have access to see this information")
            end

            self.lastModel = model
            self.lastSkin = skin
        end

        timer.Simple(0, function()
            if not IsValid(entity) or not IsValid(ply) then return end
            for _, v in ipairs(ply:GetBodyGroups()) do
                entity:SetBodygroup(v.id, ply:GetBodygroup(v.id))
            end
        end)
    end

    self.slots[#self.slots + 1] = slot
    parent:SetVisible(true)
    parent:SizeToChildren(false, true)
    parent:InvalidateLayout(true)
    local i = 0
    for _, v in ipairs(parent:GetChildren()) do
        if IsValid(v.model) then
            i = i + 1
            v.Paint = paintFunctions[i % 2]
        end
    end

    slot:update()
    return slot
end

function PANEL:OnRemove()
    CloseDermaMenus()
end

function PANEL:Paint(w, h)
    lia.util.drawBlur(self, 10)
    surface.SetDrawColor(30, 30, 30, 100)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawOutlinedRect(0, 0, w, h)
end

vgui.Register("liaScoreboard", PANEL, "EditablePanel")