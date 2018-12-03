-- Set of known compatible/incompatible plugins for your gamemode (any not in this table will use their default behaviour).
local CompatiblePlugins = {
	voterandom = true,
	votesurrender = true,
	enforceteamsizes = true,
	
	pregame = false,
	pregameplus = false,
	commbans = false,
	customspawns = false,
}
Shine.Hook.Add( "CanPluginLoad", "MyGamemodeCheck", function( Plugin, GamemodeName )
    return CompatiblePlugins[ Plugin:GetName() ]
end )