
local networkVars =
{
    numOwned = "private integer"
}
Shared.LinkClassToMap("LayMines", LayMines.kMapName, networkVars)

local oldOnUpdateRender = LayMines.OnUpdateRender
function LayMines:OnUpdateRender()
	oldOnUpdateRender(self)
    local parent = self:GetParent()
    local settings = self:GetUIDisplaySettings()
    if parent and parent:GetIsLocalPlayer() and settings then
    
        if self.ammoDisplayUI then
			self.ammoDisplayUI:SetGlobal("weaponClip", self.numOwned)
			self.ammoDisplayUI:SetGlobal("weaponMax", kMaxNumMines)
		end
	end
end

if Server then
	

    function SortMinesByAge(entities)
        local function compareAge(a, b)
            local age1 = a.timeLastHealed
            local age2 = b.timeLastHealed

            return age1 > age2
        end
        table.sort(entities, compareAge)
    end
	
	local function UpdateOwnedMines(self, player)
	
		local total = 0
		local mines = GetEntitiesForTeam("Mine", player:GetTeamNumber())
		local myMines = {}
		for _, mine in ipairs(mines) do 
			if mine:GetIsAlive() and mine:GetOwner() == player then
				total = total + 1
				table.insert(myMines, mine)
			end
		end
		
		if total > kMaxNumMines then
			SortMinesByAge(myMines)
			while total > kMaxNumMines do
				local mine = table.remove(myMines)
				mine:Kill(player, player)
				total = total - 1
			end
		end
		self.numOwned = total
	end
	
	local oldOnDraw = LayMines.OnDraw
	function LayMines:OnDraw(player, previousWeaponMapName)
		oldOnDraw(self, player, previousWeaponMapName)
		UpdateOwnedMines(self, player)
	end
	
	local oldPerformPrimaryAttack = LayMines.PerformPrimaryAttack
	function LayMines:PerformPrimaryAttack(player)
		local created_mine = oldPerformPrimaryAttack(self, player)
		if created_mine then
			UpdateOwnedMines(self, player)
		end
		return created_mine
	end

	
end