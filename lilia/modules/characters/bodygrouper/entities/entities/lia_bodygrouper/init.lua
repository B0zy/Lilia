﻿local MODULE = MODULE
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
function ENT:Initialize()
    self:SetModel(self.Model)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
end

function ENT:Use(activator)
    if activator:IsPlayer() then
        net.Start("BodygrouperMenu")
        net.Send(activator)
        self:AddUser(activator)
    end
end
