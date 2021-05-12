
-- TODO: Get this working....
--[[

local oldUpdate = GUIUnitStatus.UpdateUnitStatusBlip
function GUIUnitStatus:UpdateUnitStatusBlip( blipIndex, localPlayerIsCommander, baseResearchRot, showHints, playerTeamType )
	oldUpdate(self,  blipIndex, localPlayerIsCommander, baseResearchRot, showHints, playerTeamType )

    local blipData = self.activeStatusInfo[blipIndex]
    local updateBlip = self.activeBlipList[blipIndex]
    local blipNameText = blipData.Name
	if blipNameText == "Door" then
		local textColor = kNameTagFontColors[blipData.TeamType]
        updateBlip.NameText:SetIsVisible(true)
        updateBlip.NameText:SetText(blipNameText)
        updateBlip.NameText:SetColor(textColor)
		updateBlip.statusBg:SetIsVisible(true)
	end
	
end
]]--