ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Station Service"
ENT.Category = "Station Service"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "NPCTitle")
end
