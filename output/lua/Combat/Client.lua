Script.Load("lua/Combat/Locale.lua")

-- Setup additional GUI scripts
do
    AddClientUIScriptForTeam(kTeam1Index, "Combat/GUIExperienceBar")
    AddClientUIScriptForTeam(kTeam1Index, "Combat/GUIGameTimeCountDown")
    AddClientUIScriptForTeam(kTeam2Index, "Combat/GUIExperienceBar")
    AddClientUIScriptForTeam(kTeam2Index, "Combat/GUIGameTimeCountDown")
end



if Shine and Shine.Hook and Shine.Hook.Add then
    Shine.Hook.Add( "OnUpdateAllTalkText", "combatFunction", function( OldFunc, ... )
        -- Move the text to the left of the bottom of the screen
        return true, 0.25, 0.95
    end )
end