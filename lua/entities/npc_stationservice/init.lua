AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel(StationService.Config.NPCModel)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_BBOX)
    self:PhysicsInitStatic(SOLID_BBOX)
    self:SetCollisionBounds(Vector(-16, -16, 0), Vector(16, 16, 72))
    self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
    self:SetUseType(SIMPLE_USE)

    self:SetNWString("StationServiceNPC", "yes")
    self:SetNPCTitle(StationService.Config.NPCName)

    -- Animation idle
    local idleNames = {
        "idle_all_01", "idle_all_02", "idle_all_angry",
        "idle_subtle", "idle_male", "idle",
        "ACT_IDLE", "idle01",
    }
    local foundSeq = 0
    for _, name in ipairs(idleNames) do
        local seq = self:LookupSequence(name)
        if seq and seq > 0 then
            foundSeq = seq
            break
        end
    end
    self:ResetSequence(foundSeq)
    self:SetPlaybackRate(1)
    self:SetCycle(0)

    self:DropToFloor()
end

function ENT:Use(activator, caller, useType, value)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    local dist = activator:GetPos():DistToSqr(self:GetPos())
    if dist > (StationService.Config.InteractionDistance ^ 2) then return end

    if activator.StationServiceCooldown and activator.StationServiceCooldown > CurTime() then return end
    activator.StationServiceCooldown = CurTime() + 1

    net.Start("StationService_Open")
    net.Send(activator)
end

function ENT:OnTakeDamage(dmg)
    return false
end

function ENT:Think()
    if self:GetCycle() >= 0.99 then
        self:SetCycle(0)
    end
    self:NextThink(CurTime())
    return true
end
