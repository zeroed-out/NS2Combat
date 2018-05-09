Script.Load("lua/Combat/Locale.lua")

do
    AddClientUIScriptForTeam(kTeam1Index, "Combat/GUIExperienceBar")
    AddClientUIScriptForTeam(kTeam1Index, "Combat/GUIGameTimeCountDown")
    AddClientUIScriptForTeam(kTeam2Index, "Combat/GUIExperienceBar")
    AddClientUIScriptForTeam(kTeam2Index, "Combat/GUIGameTimeCountDown")
end