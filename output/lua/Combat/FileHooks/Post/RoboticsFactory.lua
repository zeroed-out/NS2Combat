
PrecacheAsset("materials/robo_ghost.surface_shader")
local kGhostMaterial = PrecacheAsset("materials/robo_ghost.material")

function RoboticsFactory:GetCanTakeDamageOverride()
    return false
end

function RoboticsFactory:GetCanDieOverride()
    return false
end


local function CreateGhostEffect(self)

    if not self.ghostMaterial then
        
        local model = self:GetRenderModel()
        if model then
        
			self:SetOpacity(0, "ghostEffect")
			
            local material = Client.CreateRenderMaterial()
            material:SetMaterial(kGhostMaterial)
            model:AddMaterial(material)
            self.ghostMaterial = material
        
        end
        
    end    
    
end

local function RemoveBuildEffect(self)

    if self.ghostMaterial then
      
		self:SetOpacity(1, "ghostEffect")
			
        local model = self:GetRenderModel()  
        local material = self.ghostMaterial
        model:RemoveMaterial(material)
        Client.DestroyRenderMaterial(material)
        self.ghostMaterial = nil
                    
    end            

end

local oldOnUpdate = RoboticsFactory.OnUpdate
function RoboticsFactory:OnUpdate(deltaTime)
	if (oldOnUpdate) then
		oldOnUpdate(self, deltaTime)
	end
	
	CreateGhostEffect(self)
end


