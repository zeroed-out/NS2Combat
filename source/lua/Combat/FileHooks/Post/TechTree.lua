-- Todo: Refactor/Fix this mess ~Ghoul
-- Provide a deep copy function for the tech tree.
function TechTree:CopyDataFrom(techTree)
	self.nodeList = {}
    self.techIdList = {} -- list of avaible techids (used for iterating over techtree
	-- Deep clone the node list.
	local index, oldTechNode = next(techTree.nodeList, nil)
	while index do
		local techId = oldTechNode:GetTechId()
		local newTechNode = TechNode()
        local nodeEntityId = newTechNode:GetTechId()
		newTechNode:CopyDataFrom(oldTechNode)
		self.nodeList[techId] = newTechNode
        self.techIdList[#self.techIdList + 1] = nodeEntityId
		index, oldTechNode = next(techTree.nodeList, index)
	end
    
    self.techChanged = techTree.techChanged
    self.complete = techTree.complete
    
    -- No need to add to team
    self.teamNumber = techTree.teamNumber
    
    if Server then
        self.techNodesChanged = unique_set()
        self.upgradedTechIdsSupporting = {}
		
		-- Deep clone the supporting techId list.
		for i = 1, #techTree.upgradedTechIdsSupporting do
			self.upgradedTechIdsSupporting[i] = techTree.upgradedTechIdsSupporting[i]
		end	
    end
end

-- Utility functions
function GetHasTech(callingEntity, techId, silenceError)

	if callingEntity ~= nil then

		-- In combat mode, the tech tree resides on the player not the team
		if callingEntity.GetTechTree then
			local techTree = callingEntity:GetTechTree()

			if techTree ~= nil then
				return techTree:GetHasTech(techId, silenceError)
			end
		end

	end

	return false

end

function GetIsTechAvailable()
	return true
end

function TechTree:GetIsTechAvailable()
	return true
end

-- Dont send any network updates. Save network bandwidth, save the world ;)
function TechTree:SendTechTreeBase()
end

function TechTree:SendTechTreeUpdates()
end