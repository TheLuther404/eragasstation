include("shared.lua")

function ENT:Initialize()
    self:SetRenderBounds(Vector(-50, -50, 0), Vector(50, 50, 100))
end

function ENT:Draw()
    self:DrawModel()
end

function ENT:Think()
    self:FrameAdvance(FrameTime())
end
