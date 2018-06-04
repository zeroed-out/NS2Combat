
local oldLookupTechData = LookupTechData
function LookupTechData(techId, fieldName, default)
    if fieldName == kTechDataTooltipInfo then
        if techId == kTechId.BioMassTwo then
            return "BIOMASS_TWO_TOOLTIP"
        end
        if techId == kTechId.BioMassThree then
            return "BIOMASS_THREE_TOOLTIP"
        end
    end
    return oldLookupTechData(techId, fieldName, default)
end