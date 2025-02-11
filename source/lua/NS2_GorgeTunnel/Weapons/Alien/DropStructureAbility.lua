-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Alien\DropStructureAbility.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/HydraAbility.lua")
Script.Load("lua/Weapons/Alien/ClogAbility.lua")
Script.Load("lua/NS2_GorgeTunnel/Weapons/Alien/GorgeTunnelAbility.lua")
Script.Load("lua/NS2_GorgeTunnel/Weapons/Alien/WhipAbility.lua")
Script.Load("lua/NS2_GorgeTunnel/Weapons/Alien/CragAbility.lua")
Script.Load("lua/NS2_GorgeTunnel/Weapons/Alien/ShadeAbility.lua")
Script.Load("lua/NS2_GorgeTunnel/Weapons/Alien/ShiftAbility.lua")
Script.Load("lua/Weapons/Alien/WebsAbility.lua")
Script.Load("lua/Weapons/Alien/BabblerEggAbility.lua")

class 'DropStructureAbility' (Ability)

local kMaxStructuresPerType = 20
local kDropCooldown = 1

DropStructureAbility.kMapName = "drop_structure_ability"

PrecacheAsset("sound/NS2.fev/alien/gorge/create_fail")
local kAnimationGraph = PrecacheAsset("models/alien/gorge/gorge_view.animation_graph")

DropStructureAbility.kSupportedStructures = { HydraStructureAbility, ClogAbility, WebsAbility, BabblerEggAbility, GorgeTunnelAbility, WhipStructureAbility, CragStructureAbility, ShadeStructureAbility, ShiftStructureAbility  }

local networkVars =
{
    numHydrasLeft = string.format("private integer (0 to %d)", kMaxStructuresPerType),
    numWebsLeft = string.format("private integer (0 to %d)", kMaxStructuresPerType),
    numClogsLeft = string.format("private integer (0 to %d)", kMaxStructuresPerType),
    numTunnelsLeft = string.format("private integer (0 to %d)", kMaxStructuresPerType),
    numBabblersLeft = string.format("private integer (0 to %d)", kMaxStructuresPerType),
    numStructuresLeft = string.format("private integer (0 to %d)", kMaxStructuresPerType),
}

function DropStructureAbility:GetAnimationGraphName()
    return kAnimationGraph
end

function DropStructureAbility:GetActiveStructure()

    if self.activeStructure == nil then
        return nil
    else
        return DropStructureAbility.kSupportedStructures[self.activeStructure]
    end

end

function DropStructureAbility:OnCreate()

    Ability.OnCreate(self)

    self.dropping = false
    self.mouseDown = false
    self.activeStructure = nil

    -- for GUI
    self.numHydrasLeft = 0
    self.numWebsLeft = 0
    self.numClogsLeft = 0
    self.numTunnelsLeft = 0
    self.numBabblersLeft = 0
    self.numStructuresLeft = 0
    self.lastClickedPosition = nil
    self.lastClickedPositionNormal = nil

	self.timeNextUpdatedDropStructure = 0
end

function DropStructureAbility:GetDeathIconIndex()
    return kDeathMessageIcon.Consumed
end

function DropStructureAbility:SetActiveStructure(structureNum)

    self.activeStructure = structureNum
    self.lastClickedPosition = nil
    self.lastClickedPositionNormal = nil

end

function DropStructureAbility:GetHasDropCooldown()
    return self.timeLastDrop ~= nil and self.timeLastDrop + kDropCooldown > Shared.GetTime()
end

function DropStructureAbility:GetSecondaryTechId()
    return kTechId.Spray
end

function DropStructureAbility:GetNumStructuresBuilt(techId)

    if techId == kTechId.Hydra then
        return self.numHydrasLeft
    end

    if techId == kTechId.Clog then
        return self.numClogsLeft
    end
    
    if techId == kTechId.GorgeTunnel then
        return self.numTunnelsLeft
    end
    
    if techId == kTechId.Web then
        return self.numWebsLeft
    end

    if techId == kTechId.BabblerEgg then
        return self.numBabblersLeft
    end
    
    if techId == kTechId.GorgeCrag or techId == kTechId.GorgeShade or techId == kTechId.GorgeShift or techId == kTechId.GorgeWhip then
        return self.numStructuresLeft
    end
    
    -- unlimited
    return -1
end

function DropStructureAbility:OnPrimaryAttack(player)

    if Client then

        if self.activeStructure
                and not self.dropping
                and not self.mouseDown then

            self.mouseDown = true

            if player:GetEnergy() >= self:GetEnergyCost() then

                if self:PerformPrimaryAttack(player) then
                    self.dropping = true
                end

            else
                player:TriggerInvalidSound()
            end

        end

    end

end

function DropStructureAbility:OnPrimaryAttackEnd()

    if not Shared.GetIsRunningPrediction() then

        if Client and self.dropping then
            self:OnSetActive()
        end

        self.dropping = false
        self.mouseDown = false

    end

end

function DropStructureAbility:GetIsDropping()
    return self.dropping
end

function DropStructureAbility:GetEnergyCost()
    local activeStructure = self:GetActiveStructure()
    if activeStructure then
        return activeStructure:GetEnergyCost()
    end

    return kDropStructureEnergyCost
end

function DropStructureAbility:GetDamageType()
    return kHealsprayDamageType
end

function DropStructureAbility:GetHUDSlot()
    return 2
end

function DropStructureAbility:GetHasSecondary(player)
    return true
end

function DropStructureAbility:OnSecondaryAttack(player)

    if player and self.previousWeaponMapName and player:GetWeapon(self.previousWeaponMapName) then
        player:SetActiveWeapon(self.previousWeaponMapName)
    end

end

function DropStructureAbility:GetSecondaryEnergyCost()
    return 0
end

function DropStructureAbility:PerformPrimaryAttack(player)

    if self.activeStructure == nil then
        return false
    end

    local success = false

    -- Ensure the current location is valid for placement.
    local coords, valid, _, normal = self:GetPositionForStructure(player:GetEyePos(), player:GetViewCoords().zAxis, self:GetActiveStructure(), self.lastClickedPosition, self.lastClickedPositionNormal)
    local secondClick = true

    if LookupTechData(self:GetActiveStructure().GetDropStructureId(), kTechDataSpecifyOrientation, false) then
        secondClick = self.lastClickedPosition ~= nil
    end

    if secondClick then

        if valid then

            -- Ensure they have enough resources.
            local cost = GetCostForTech(self:GetActiveStructure().GetDropStructureId())
            if player:GetResources() >= cost and not self:GetHasDropCooldown() then

                local message = BuildGorgeDropStructureMessage(player:GetEyePos(), player:GetViewCoords().zAxis, self.activeStructure, self.lastClickedPosition, self.lastClickedPositionNormal)
                Client.SendNetworkMessage("GorgeBuildStructure", message, true)
                self.timeLastDrop = Shared.GetTime()
                success = true

            end

        end

        self.lastClickedPosition = nil
        self.lastClickedPositionNormal = nil

    elseif valid then
        self.lastClickedPosition = Vector(coords.origin)
        self.lastClickedPositionNormal = normal

    end

    if not valid then
        player:TriggerInvalidSound()
    end

    return success

end

function DropStructureAbility:DropStructure(player, origin, direction, structureAbility, lastClickedPosition, lastClickedPositionNormal)

    -- If we have enough resources
    if Server then

        local coords, valid, onEntity = self:GetPositionForStructure(origin, direction, structureAbility, lastClickedPosition, lastClickedPositionNormal)
        local techId = structureAbility:GetDropStructureId()

        local maxStructures = -1

        if not LookupTechData(techId, kTechDataAllowConsumeDrop, false) then
            maxStructures = LookupTechData(techId, kTechDataMaxAmount, 0)
        end

        valid = valid and self:GetNumStructuresBuilt(techId) ~= maxStructures -- -1 is unlimited

		--Print("%s built %d  max %d", ToString(valid), self:GetNumStructuresBuilt(techId), maxStructures)
        local cost = LookupTechData(structureAbility:GetDropStructureId(), kTechDataCostKey, 0)
        local enoughRes = player:GetResources() >= cost
        local energyCost = structureAbility:GetEnergyCost()
        local enoughEnergy = player:GetEnergy() >= energyCost

        if valid and enoughRes and structureAbility:IsAllowed(player) and enoughEnergy and not self:GetHasDropCooldown() then
			
            -- Create structure
            local structure = self:CreateStructure(coords, player, structureAbility)

            if structure then
			
                structure:SetOwner(player)
                if structure.EnableGorgeOwner then
                    structure:EnableGorgeOwner()
                end
                if HasMixin(structure, "ClogFall") then
                    if onEntity then
                        if onEntity:isa("Clog") then
                            onEntity:ConnectToClog(structure)
                        elseif structure:isa("Clog") and onEntity:isa("Web") then
                            onEntity:ConnectToClog(structure)
                        else
                            structure.fallWaiting = 0.0
                            structure:SetUpdates(true, kDefaultUpdateRate)
                        end
                    else
                        -- touching level, therefore can never move again, as the level doesn't move.
                        structure.doneFalling = true
                    end
                end

                player:GetTeam():AddGorgeStructure(player, structure)

                -- Check for space
                if structure:SpaceClearForEntity(coords.origin) then

                    local angles = Angles()

                    if structure:isa("BabblerEgg") and coords.yAxis.y > 0.8 then
                        angles.yaw = math.random() * math.pi * 2

                    elseif structure:isa("Clog") then

                        angles.yaw = math.random() * math.pi * 2
                        angles.pitch = math.random() * math.pi * 2
                        angles.roll = math.random() * math.pi * 2
                        
                    elseif structure:isa("TunnelEntrance") then
                        angles:BuildFromCoords(coords)
                    else
                        angles:BuildFromCoords(coords)
                    end

                    structure:SetAngles(angles)

                    if structure.SetVariant then
                        structure:SetVariant(player:GetVariant())
                    end

                    if structure.OnCreatedByGorge then
                        structure:OnCreatedByGorge()
                    end

                    player:AddResources(-cost)

                    player:DeductAbilityEnergy(energyCost)
                    player:TriggerEffects("spit_structure", {effecthostcoords = Coords.GetLookIn(origin, direction)} )

                    if structureAbility.OnStructureCreated then
                        structureAbility:OnStructureCreated(structure, lastClickedPosition)
                    end

                    self.timeLastDrop = Shared.GetTime()

                    return true

                else

                    player:TriggerInvalidSound()
                    DestroyEntity(structure)

                end

            else
                player:TriggerInvalidSound()
            end

        else

            if not valid then
                player:TriggerInvalidSound()
            elseif not enoughRes then
                player:TriggerInvalidSound()
            end

        end

    end

    return true

end

function DropStructureAbility:OnDropStructure(origin, direction, structureIndex, lastClickedPosition, lastClickedPositionNormal)

    local player = self:GetParent()

    if player then

        local structureAbility = DropStructureAbility.kSupportedStructures[structureIndex]
        if structureAbility then
            self:DropStructure(player, origin, direction, structureAbility, lastClickedPosition, lastClickedPositionNormal)
        end

    end

end

function DropStructureAbility:CreateStructure(coords, player, structureAbility, lastClickedPosition)
    local created_structure = structureAbility:CreateStructure(coords, player, lastClickedPosition)
    if created_structure then
        return created_structure
    else
        return CreateEntity(structureAbility:GetDropMapName(), coords.origin, player:GetTeamNumber())
    end
end

local function FilterBabblersAndTwo(ent1, ent2)
    return function (test) return test == ent1 or test == ent2 or test:isa("Babbler") end
end

-- Given a gorge player's position and view angles, return a position and orientation
-- for structure. Used to preview placement via a ghost structure and then to create it.
-- Also returns bool if it's a valid position or not.
function DropStructureAbility:GetPositionForStructure(startPosition, direction, structureAbility, lastClickedPosition, lastClickedPositionNormal)

    PROFILE("DropStructureAbility:GetPositionForStructure")

    local validPosition = false
    local range = structureAbility:GetDropRange(lastClickedPosition)
    local origin = startPosition + direction * range
    local player = self:GetParent()

    -- Trace short distance in front
    local trace = Shared.TraceRay(player:GetEyePos(), origin, CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, FilterBabblersAndTwo(player, self))

    local displayOrigin = trace.endPoint


    -- If we hit nothing, try a slightly bigger ray
    if trace.fraction == 1 then

        local boxTrace = Shared.TraceBox(Vector(0.2,0.2,0.2), player:GetEyePos(), origin,  CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, EntityFilterTwo(player, self))
        if boxTrace.entity and boxTrace.entity:isa("Web") then
            trace = boxTrace
        end

    end

    -- If we still hit nothing, trace down to place on ground
    if trace.fraction == 1 then

        origin = startPosition + direction * range
        trace = Shared.TraceRay(origin, origin - Vector(0, range, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, FilterBabblersAndTwo(player, self))

    end

    -- If it hits something, position on this surface (must be the world or another structure)
    if trace.fraction < 1 then

        if trace.entity == nil then
            validPosition = true

        elseif trace.entity:isa("Infestation") or trace.entity:isa("Clog") then
            validPosition = true
        elseif trace.entity:isa("Web") and structureAbility.GetDropMapName() == Clog.kMapName then
            -- Allow up to 3 entites on a web
            validPosition = true
        end

        displayOrigin = trace.endPoint

    end

    -- Can only be built on infestation
    local requiresInfestation = LookupTechData(structureAbility.GetDropStructureId(), kTechDataRequiresInfestation)
    if requiresInfestation and not GetIsPointOnInfestation(displayOrigin) then

        if self:GetActiveStructure().OverrideInfestationCheck then
            validPosition = self:GetActiveStructure():OverrideInfestationCheck(trace)
        else
            validPosition = false
        end

    end

    if not structureAbility.AllowBackfacing() and trace.normal:DotProduct(GetNormalizedVector(startPosition - trace.endPoint)) < 0 then
        validPosition = false
    end

    -- Don't allow dropped structures to go too close to techpoints and resource nozzles
    if GetPointBlocksAttachEntities(displayOrigin) then
        validPosition = false
    end

    if not structureAbility:GetIsPositionValid(displayOrigin, player, trace.normal, lastClickedPosition, lastClickedPositionNormal, trace.entity) then
        validPosition = false
    end

    if trace.surface == "nocling" then
        validPosition = false
    end

    -- Don't allow placing above or below us and don't draw either
    local structureFacing = Vector(direction)

    if math.abs(Math.DotProduct(trace.normal, structureFacing)) > 0.9 then
        structureFacing = trace.normal:GetPerpendicular()
    end

    -- Coords.GetLookIn will prioritize the direction when constructing the coords,
    -- so make sure the facing direction is perpendicular to the normal so we get
    -- the correct y-axis.
    local perp = Math.CrossProduct( trace.normal, structureFacing )
    structureFacing = Math.CrossProduct( perp, trace.normal )

    local coords = Coords.GetLookIn( displayOrigin, structureFacing, trace.normal )

    if structureAbility.ModifyCoords then
        structureAbility:ModifyCoords(coords, lastClickedPosition, trace.normal, player)
    end

    -- perform a final check to ensure the gorge isn't trying to build from inside a clog.
    if GetIsPointInsideClogs(player:GetEyePos()) then
        validPosition = false
    end

    return coords, validPosition, trace.entity, trace.normal

end

function DropStructureAbility:OnDraw(player, previousWeaponMapName)

    Ability.OnDraw(self, player, previousWeaponMapName)

    self.previousWeaponMapName = previousWeaponMapName
    self.dropping = false
    self.activeStructure = nil

end

function DropStructureAbility:OnTag(tagName)
    if tagName == "shoot" then
        self.dropping = false
    end
end

function DropStructureAbility:OnUpdateAnimationInput(modelMixin)

    PROFILE("DropStructureAbility:OnUpdateAnimationInput")

    modelMixin:SetAnimationInput("ability", "chamber")

    local activityString = "none"
    if self.dropping then
        activityString = "primary"
    end
    modelMixin:SetAnimationInput("activity", activityString)

end

function DropStructureAbility:ProcessMoveOnWeapon(input)

	if self.timeNextUpdatedDropStructure < Shared.GetTime() then
		-- Show ghost if we're able to create structure, and if menu is not visible
		self.timeNextUpdatedDropStructure = Shared.GetTime() + 0.5
		
		local player = self:GetParent()
		if player then

			if Server then

				local team = player:GetTeam()
				local numAllowedHydras = LookupTechData(kTechId.Hydra, kTechDataMaxAmount, -1)
				local numAllowedClogs = LookupTechData(kTechId.Clog, kTechDataMaxAmount, -1)
				local numAllowedTunnels = LookupTechData(kTechId.GorgeTunnel, kTechDataMaxAmount, -1)
				local numAllowedWebs = LookupTechData(kTechId.Web, kTechDataMaxAmount, -1)
				local numAllowedBabblers = LookupTechData(kTechId.BabblerEgg, kTechDataMaxAmount, -1)
				local numAllowedStructures = LookupTechData(kTechId.GorgeWhip, kTechDataMaxAmount, -1)

				--Print("max allowed "..ToString(numAllowedStructures))
				if numAllowedHydras >= 0 then
					self.numHydrasLeft = team:GetNumDroppedGorgeStructures(player, kTechId.Hydra)
				end

				if numAllowedClogs >= 0 then
					self.numClogsLeft = team:GetNumDroppedGorgeStructures(player, kTechId.Clog)
				end
				
				if numAllowedTunnels >= 0 then
					self.numTunnelsLeft = team:GetNumDroppedGorgeStructures(player, kTechId.GorgeTunnel)
				end
				
				if numAllowedWebs >= 0 then
					self.numWebsLeft = team:GetNumDroppedGorgeStructures(player, kTechId.Web)
				end

				if numAllowedBabblers >= 0 then
					self.numBabblersLeft = team:GetNumDroppedGorgeStructures(player, kTechId.BabblerEgg)
				end
		
				if numAllowedStructures >= 0 then
					self.numStructuresLeft = team:GetNumDroppedGorgeStructures(player, kTechId.GorgeWhip) + team:GetNumDroppedGorgeStructures(player, kTechId.GorgeCrag) + team:GetNumDroppedGorgeStructures(player, kTechId.GorgeShift) + team:GetNumDroppedGorgeStructures(player, kTechId.GorgeShade)
				end
			end

		end
	end
	
end

function DropStructureAbility:GetShowGhostModel()
    return self.activeStructure ~= nil and not self:GetHasDropCooldown()
end

function DropStructureAbility:GetGhostModelCoords()
    return self.ghostCoords
end

function DropStructureAbility:GetIsPlacementValid()
    return self.placementValid
end

function DropStructureAbility:GetIgnoreGhostHighlight()
    if self.activeStructure ~= nil and self:GetActiveStructure().GetIgnoreGhostHighlight then
        return self:GetActiveStructure():GetIgnoreGhostHighlight()
    end

    return false

end

function DropStructureAbility:GetGhostModelTechId()

    if self.activeStructure == nil then
        return nil
    else
        return self:GetActiveStructure():GetDropStructureId()
    end

end

function DropStructureAbility:GetGhostModelName(player)

    if self.activeStructure ~= nil and self:GetActiveStructure().GetGhostModelName then
        return self:GetActiveStructure():GetGhostModelName(self)
    end

    return nil

end

if Client then

    function DropStructureAbility:OnProcessIntermediate(input)

        local player = self:GetParent()
        local viewDirection = player:GetViewCoords().zAxis

        if player and self.activeStructure then

            self.ghostCoords, self.placementValid = self:GetPositionForStructure(player:GetEyePos(), viewDirection, self:GetActiveStructure(), self.lastClickedPosition, self.lastClickedPositionNormal)

            if player:GetResources() < LookupTechData(self:GetActiveStructure():GetDropStructureId(), kTechDataCostKey) then
                self.placementValid = false
            end

        end

    end

    function DropStructureAbility:CreateBuildMenu()

        if not self.buildMenu then
            self.buildMenu = GetGUIManager():CreateGUIScript("GUIGorgeBuildMenu")
        end

    end

    function DropStructureAbility:DestroyBuildMenu()

        if self.buildMenu ~= nil then

            GetGUIManager():DestroyGUIScript(self.buildMenu)
            self.buildMenu = nil

        end

    end

    function DropStructureAbility:OnDestroy()

        self:DestroyBuildMenu()
        Ability.OnDestroy(self)

    end

    function DropStructureAbility:OnKillClient()
        self.menuActive = false
    end

    function DropStructureAbility:OnDrawClient()

        Ability.OnDrawClient(self)

        -- We need this here in case we switch to it via Prev/NextWeapon keys

        -- Do not show menu for other players or local spectators.
        local player = self:GetParent()
        if player:GetIsLocalPlayer() and self:GetActiveStructure() == nil and Client.GetIsControllingPlayer() then
            self.menuActive = true
        end

    end

    local function UpdateGUI(self, player)

        local localPlayer = Client.GetLocalPlayer()
        if localPlayer == player then
            self:CreateBuildMenu()
        end

        if self.buildMenu then
            self.buildMenu:SetIsVisible(player and localPlayer == player and player:isa("Gorge") and self.menuActive and not HelpScreen_GetHelpScreen():GetIsBeingDisplayed() and not GetMainMenu():GetVisible())
        end

    end

    function DropStructureAbility:OnHolsterClient()

        self.menuActive = false
        Ability.OnHolsterClient(self)
        self.activeStructure = nil

    end

    function DropStructureAbility:OnSetActive()
    end

    function DropStructureAbility:OverrideInput(input)

        if self.buildMenu then

            -- Build menu is up, let it handle input
            if self.buildMenu:GetIsVisible() then

                local selected = false
                input, selected = self.buildMenu:OverrideInput(input)
                self.menuActive = not selected

            else

                -- If player wants to switch to this, open build menu immediately
                -- reload for whip
                -- drop for crag
                -- use for shade
                -- ToggleFlashlight for shift
                local weaponSwitchCommands = { Move.Weapon1, Move.Weapon2, Move.Weapon3, Move.Weapon4, Move.Weapon5, Move.Reload, Move.Drop, Move.Use, Move.ToggleFlashlight }
                local thisCommand = weaponSwitchCommands[ self:GetHUDSlot() ]

                if bit.band( input.commands, thisCommand ) ~= 0 then
                    self.menuActive = true
                end

            end

        end

        return input

    end

    function DropStructureAbility:OnUpdateRender()
        UpdateGUI(self, self:GetParent())
    end

end

Shared.LinkClassToMap("DropStructureAbility", DropStructureAbility.kMapName, networkVars)