ShadeInk.kInkRange = 10 -- kScanRadius is 20

-- make the effect the same for both teams
ShadeInk.kShadeInkMarineEffect = PrecacheAsset("cinematics/shade_ink.cinematic")
ShadeInk.kShadeInkAlienEffect = ShadeInk.kShadeInkMarineEffect

function ShadeInk:GetUpdateTime()
    return 0.1 -- was 2.0
end

if Server then

    function ShadeInk:Perform()
	
        DestroyEntitiesWithinRange("Scan", self:GetOrigin(), Scan.kScanDistance) 
		
		-- FYI detectable is not the same as sighted
		local ents = GetEntitiesWithMixinForTeamWithinRange("Detectable", self:GetTeamNumber(), self:GetOrigin(), ShadeInk.kInkRange)
		for _, ent in ipairs(ents) do
		
			if ent.SetDetected then
				ent:SetDetected(false)
			end
			
		end
	end
	
end