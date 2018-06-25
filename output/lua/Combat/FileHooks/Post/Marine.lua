-- Weapons can't be dropped anymore
function Marine:Drop()

	-- just do nothing

end


local networkVars =
{
    timeCatpackboost = "private time" -- remove compensated so we can do it outside of moves
}
Shared.LinkClassToMap("Marine", Marine.kMapName, networkVars, true)