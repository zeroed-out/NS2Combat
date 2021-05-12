
local oldInitTechTree = MarineTeam.InitTechTree
function MarineTeam:InitTechTree()
    local disable = function() end
    local oldPlayingTeamInitTechTree = PlayingTeam.InitTechTree
    
    PlayingTeam.InitTechTree(self)
    
    self.techTree:AddResearchNode(kTechId.ShieldGeneratorTech,           kTechId.Armory, kTechId.None)
    self.techTree:AddResearchNode(kTechId.ShieldGeneratorTech2,          kTechId.ShieldGeneratorTech, kTechId.None)
    self.techTree:AddResearchNode(kTechId.ShieldGeneratorTech3,          kTechId.ShieldGeneratorTech2, kTechId.None)
    self.techTree:AddBuyNode(kTechId.ShieldGenerator,                    kTechId.ShieldGeneratorTech, kTechId.None)
    
    
    PlayingTeam.InitTechTree = disable
    oldInitTechTree(self)
    PlayingTeam.InitTechTree = oldPlayingTeamInitTechTree
    
end