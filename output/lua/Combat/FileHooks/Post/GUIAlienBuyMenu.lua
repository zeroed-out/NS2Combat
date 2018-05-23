Script.Load("lua/GUIAssets.lua")

-- Todo: Refactor GUIAlienBuyMenu to make it easier to modify without having to copy all those local methods
local kFont = Fonts.kAgencyFB_Small

GUIAlienBuyMenu.kUpgradeButtonDistance = GUIScale(kCombatAlienBuyMenuUpgradeButtonDistance)
GUIAlienBuyMenu.kRefundButtonWidth = GUIScale(80)
GUIAlienBuyMenu.kRefundButtonHeight = GUIScale(80)
GUIAlienBuyMenu.kRefundButtonYOffset = GUIScale(20)
GUIAlienBuyMenu.kRefundButtonTextSize = GUIScale(22)
GUIAlienBuyMenu.kRefundButtonTextureCoordinates = { 396, 428, 706, 511 }

-- Create a 'refund' button
local function InitializeRefundButton(self)

    self.refundButtonBackground = GUIManager:CreateGraphicItem()
    self.refundButtonBackground:SetAnchor(GUIItem.Right, GUIItem.Bottom)
    self.refundButtonBackground:SetSize(Vector(GUIAlienBuyMenu.kRefundButtonWidth, GUIAlienBuyMenu.kRefundButtonHeight, 0))
    self.refundButtonBackground:SetPosition(Vector(-GUIAlienBuyMenu.kRefundButtonWidth / 2, GUIAlienBuyMenu.kRefundButtonHeight / 2 + GUIAlienBuyMenu.kRefundButtonYOffset, 0))
    self.refundButtonBackground:SetTexture(GUIAlienBuyMenu.kBuyMenuTexture)
    self.refundButtonBackground:SetTexturePixelCoordinates(GUIUnpackCoords(GUIAlienBuyMenu.kRefundButtonTextureCoordinates))
    self.background:AddChild(self.refundButtonBackground)

    self.refundButtonText = GUIManager:CreateTextItem()
    self.refundButtonText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    self.refundButtonText:SetFontName(kFont)
    self.refundButtonText:SetTextAlignmentX(GUIItem.Align_Center)
    self.refundButtonText:SetTextAlignmentY(GUIItem.Align_Center)
    self.refundButtonText:SetText(Combat_ResolveString("COMBAT_REFUND_ALIEN"))
    self.refundButtonText:SetColor(Color(242, 214, 42, 1))
    self.refundButtonText:SetPosition(Vector(0, 0, 0))
    self.refundButtonBackground:AddChild(self.refundButtonText)

end

local old_InitializeSlots = GUIAlienBuyMenu._InitializeSlots
local CreateSlot
function GUIAlienBuyMenu:_InitializeSlots()

    -- For the first version of this, just make a slot for each upgrade.
     self.slots = {}
    
    for i, upgrade in ipairs(UpsList) do
        if (upgrade:GetTeam() == "Alien" and upgrade:GetType() ~= kCombatUpgradeTypes.Class) then
            CreateSlot(self, upgrade:GetTechId())
        end
    end
    
    local anglePerSlot = (math.pi * kCombatAlienBuyMenuTotalAngle) / (#self.slots-1)
    
    for i = 1, #self.slots do
    
        local angle = (i-1) * anglePerSlot + math.pi * 0.2
        local distance = GUIAlienBuyMenu.kSlotDistance
        
        self.slots[i].Graphic:SetPosition( Vector( math.cos(angle) * distance - GUIAlienBuyMenu.kSlotSize * .5, math.sin(angle) * distance - GUIAlienBuyMenu.kSlotSize * .5, 0) )
        self.slots[i].Angle = angle
    
    end


    -- Create the refund button too.
    InitializeRefundButton(self)
end
debug.joinupvalues(GUIAlienBuyMenu._InitializeSlots, old_InitializeSlots) -- Todo: Make CreateSlot a class method

local old_InitializeUpgradeButtons = GUIAlienBuyMenu._InitializeUpgradeButtons
function GUIAlienBuyMenu:_InitializeUpgradeButtons()
    old_InitializeUpgradeButtons(self)

    -- set up costs of each upgrade
    for _, button in ipairs(self.upgradeButtons) do
        button.Cost = GetUpgradeFromTechId(button.TechId):GetLevels()
    end
end

local function GetSelectedUpgradesCost(self)

    local cost = 0
    local purchasedTech = GetPurchasedTechIds()

    -- Only count upgrades that we've selected and don't already own.
    for _, currentButton in ipairs(self.upgradeButtons) do
    
        if currentButton.Selected then

            local isPurchased = false

            for _, purchasedTechId in ipairs(purchasedTech) do
                if currentButton.TechId == purchasedTechId then
                    isPurchased = true
                    break
                end
            end

            -- If the upgrade isn't purchased add the cost.
            if not isPurchased then
                cost = cost + currentButton.Cost
            end

        end
        
    end
    
    return cost
    
end

local function GetNumberOfSelectedUpgrades(self)

    local numSelected = 0
    for _, currentButton in ipairs(self.upgradeButtons) do
    
        if currentButton.Selected and not currentButton.Purchased then
            numSelected = numSelected + 1
        end
        
    end
    
    return numSelected
    
end

local function GetCanAffordAlienTypeAndUpgrades(self, alienType)

    local alienCost = AlienBuy_GetAlienCost(alienType)
    local upgradesCost = GetSelectedUpgradesCost(self)
    -- Cannot buy the current alien without upgrades.
    if alienType == AlienBuy_GetCurrentAlien() then
        alienCost = 0
    end

    return PlayerUI_GetPlayerResources() >= alienCost + upgradesCost
    
end

--
-- Returns true if the player has a different Alien or any upgrade selected.
--
local function GetAlienOrUpgradeSelected(self)
    return self.selectedAlienType ~= AlienBuy_GetCurrentAlien() or GetNumberOfSelectedUpgrades(self) > 0
end

local function UpdateEvolveButton(self)

    local researched, researchProgress, researching = self:_GetAlienTypeResearchInfo(GUIAlienBuyMenu.kAlienTypes[self.selectedAlienType].Index)
    local selectedUpgradesCost = GetSelectedUpgradesCost(self)
    local numberOfSelectedUpgrades = GetNumberOfSelectedUpgrades(self)
    local evolveButtonTextureCoords = GUIAlienBuyMenu.kEvolveButtonTextureCoordinates
    
    local evolveText = Combat_ResolveString("ABM_SELECT_UPGRADES")
    local evolveCost
    
    -- If the current alien is selected with no upgrades, cannot evolve.
    if self.selectedAlienType == AlienBuy_GetCurrentAlien() and numberOfSelectedUpgrades == 0 then
        evolveButtonTextureCoords = GUIAlienBuyMenu.kEvolveButtonNeedResourcesTextureCoordinates
        
    elseif not GetCanAffordAlienTypeAndUpgrades(self, self.selectedAlienType) then
    
        -- If cannot afford selected alien type and/or upgrades, cannot evolve.
        evolveButtonTextureCoords = GUIAlienBuyMenu.kEvolveButtonNeedResourcesTextureCoordinates
        evolveText = Combat_ResolveString("ABM_NEED")
        evolveCost = AlienBuy_GetAlienCost(self.selectedAlienType) + selectedUpgradesCost
        
    else
    
        -- Evolution is possible! Darwin would be proud.
        local totalCost = selectedUpgradesCost
        
        -- Cannot buy the current alien.
        if self.selectedAlienType ~= AlienBuy_GetCurrentAlien() then
            totalCost = totalCost + AlienBuy_GetAlienCost(self.selectedAlienType)
        end
        
        evolveText = Combat_ResolveString("ABM_EVOLVE_FOR")
        evolveCost = totalCost
        
    end
            
    self.evolveButtonBackground:SetTexturePixelCoordinates(GUIUnpackCoords(evolveButtonTextureCoords))
    self.evolveButtonText:SetText(evolveText)
    self.evolveResourceIcon:SetIsVisible(evolveCost ~= nil)
    local totalEvolveButtonTextWidth = 0
    
    if evolveCost ~= nil then
    
        local evolveCostText = ToString(evolveCost)
        self.evolveButtonResAmount:SetText(evolveCostText)
        totalEvolveButtonTextWidth = totalEvolveButtonTextWidth + self.evolveResourceIcon:GetSize().x +
                                     self.evolveButtonResAmount:GetTextWidth(evolveCostText)
        
    end
    
    self.evolveButtonText:SetPosition(Vector(-totalEvolveButtonTextWidth / 2, 0, 0))
    
    local allowedToEvolve = not researching and GetCanAffordAlienTypeAndUpgrades(self, self.selectedAlienType) and hasGameStarted
    allowedToEvolve = allowedToEvolve and GetAlienOrUpgradeSelected(self)
    local veinsAlpha = 0
    self.evolveButtonBackground:SetScale(Vector(1, 1, 0))
    
    if allowedToEvolve then
    
        if self:_GetIsMouseOver(self.evolveButtonBackground) then
        
            veinsAlpha = 1
            self.evolveButtonBackground:SetScale(Vector(1.1, 1.1, 0))
            
        else
            veinsAlpha = (math.sin(Shared.GetTime() * 4) + 1) / 2
        end
        
    end
    
    self.evolveButtonVeins:SetColor(Color(1, 1, 1, veinsAlpha))
    
end

local kDefaultColor = Color(kIconColors[kAlienTeamType])
local kNotAvailableColor = Color(0.3, 0.3, 0.3, 1)
local kNotAllowedColor = Color(1, 0, 0, 1)
local kPurchasedColor = Color(1, 0.6, 0, 1)

local function UpdateRefundButton(self)

    if self:_GetIsMouseOver(self.refundButtonBackground) then
        local infoText = Combat_ResolveString("COMBAT_REFUND_TITLE_ALIEN")
        local infoTip = Combat_ResolveString("COMBAT_REFUND_DESCRIPTION_ALIEN")
        self:_ShowMouseOverInfo(infoText, infoTip, 0, 0, 0)
    end

end

local oldUpdate = GUIAlienBuyMenu.Update
function GUIAlienBuyMenu:Update(deltaTime)

    oldUpdate(self, deltaTime)

    -- Call our version of the evolve button script.
    UpdateEvolveButton(self)

    -- Hide all the slots.
    for _, slot in ipairs(self.slots) do
        slot.Graphic:SetIsVisible(false)
    end

    local lvlFree = PlayerUI_GetPersonalResources()

    -- Override the colours per our schema.
    -- Always show, unless we can't afford the upgrade or it is not allowed.
    for _, currentButton in ipairs(self.upgradeButtons) do
        local useColor = kDefaultColor

        if currentButton.Purchased then
            useColor = kPurchasedColor
        elseif currentButton.Cost > lvlFree then
            useColor = kNotAvailableColor
        end

        if not currentButton.Selected and not AlienBuy_GetIsUpgradeAllowed(currentButton.TechId, self.upgradeList) then
            useColor = kNotAllowedColor
        end

        currentButton.Icon:SetColor(useColor)

        if self:_GetIsMouseOver(currentButton.Icon) then
       
           local currentUpgradeInfoText = GetDisplayNameForTechId(currentButton.TechId)
           local tooltipText = GetTooltipInfoText(currentButton.TechId)

           self:_ShowMouseOverInfo(currentUpgradeInfoText, tooltipText, currentButton.Cost)
           
       end
    end

    UpdateRefundButton(self)

end

local function ClickRefundButton(self)

    Shared.ConsoleCommand("co_refundall")

end

function GUIAlienBuyMenu:SendKeyEvent(key, down)

    local closeMenu = false
    local inputHandled = false
    
    if key == InputKey.MouseButton0 and self.mousePressed ~= down then
    
        self.mousePressed = down
        
        local mouseX, mouseY = Client.GetCursorPosScreen()
        if down then
        
            -- Check if the evolve button was selected.
            local allowedToEvolve = GetCanAffordAlienTypeAndUpgrades(self, self.selectedAlienType)
            allowedToEvolve = allowedToEvolve and GetAlienOrUpgradeSelected(self)
            if allowedToEvolve and self:_GetIsMouseOver(self.evolveButtonBackground) then
            
                local purchases = { }
                -- Buy the selected alien if we have a different one selected.
                
                if self.selectedAlienType ~= AlienBuy_GetCurrentAlien() then
                    if AlienBuy_GetCurrentAlien() == 5 then
                        -- only buy another class when youre a skulk
                        table.insert(purchases, AlienBuy_GetTechIdForAlien(self.selectedAlienType))
                    end
                end

                -- Buy all selected upgrades.
                for i, currentButton in ipairs(self.upgradeButtons) do

                    if currentButton.Selected then
                        table.insert(purchases, currentButton.TechId ) -- Combat uses only the techIds !!!
                    end

                end
                
                closeMenu = true
                inputHandled = true

                if #purchases > 0 then
                    AlienBuy_Purchase(purchases)
                end
                
                AlienBuy_OnPurchase()
                
            end
            
            inputHandled = self:_HandleUpgradeClicked(mouseX, mouseY) or inputHandled
            
            if not inputHandled then
            
                -- Check if an alien was selected.
                for k, buttonItem in ipairs(self.alienButtons) do
                    
                    local researched, researchProgress, researching = self:_GetAlienTypeResearchInfo(buttonItem.TypeData.Index)
                    if (researched or researching) and self:_GetIsMouseOver(buttonItem.Button) then
                        
                        if (AlienBuy_GetCurrentAlien() == 5) then
                            -- Deselect all upgrades when a different alien type is selected.
                            if self.selectedAlienType ~= buttonItem.TypeData.Index  then
                                AlienBuy_OnSelectAlien(GUIAlienBuyMenu.kAlienTypes[buttonItem.TypeData.Index].Name)
                            end
                            
                            self.selectedAlienType = buttonItem.TypeData.Index
                            inputHandled = true
                            break
    
                        end
                        
                    end
                    
                end

                if self:_GetIsMouseOver(self.refundButtonBackground) then
                    ClickRefundButton(self)
                    closeMenu = true
                    inputHandled = true
                    AlienBuy_OnClose()
                end
                
                -- Check if the close button was pressed.
                if not closeMenu then
                    if self:_GetIsMouseOver(self.closeButton) then

                        closeMenu = true
                        inputHandled = true
                        AlienBuy_OnClose()

                    end
                end
                
            end
            
        end
        
    end
    
    -- AlienBuy_Close() must be the last thing called.
    if closeMenu then
    
        self.closingMenu = true
        local player = Client.GetLocalPlayer()
        player:CloseMenu(true)
        
    end
    
    return inputHandled
    
end

-- only 1 upgrade should be selectable
local function _GetHasMaximumSelected(self)
    -- only 1 upgrade should be selectable, but already bought ups are OK
    return false
end

local old_UninitializeUpgradeButtons = GUIAlienBuyMenu._UninitializeUpgradeButtons
function GUIAlienBuyMenu:_UninitializeUpgradeButtons()

    old_UninitializeUpgradeButtons(self)

    GUI.DestroyItem(self.refundButtonText)
    self.refundButtonText = nil

    GUI.DestroyItem(self.refundButtonBackground)
    self.refundButtonBackground = nil

end

local old_HandleUpgradeClicked = GUIAlienBuyMenu._HandleUpgradeClicked
local ToggleButton
function GUIAlienBuyMenu:_HandleUpgradeClicked()
    local inputHandled = false

    for _, currentButton in ipairs(self.upgradeButtons) do
        -- Can't select if it has been purchased already or is unselectable.
        if (not _GetHasMaximumSelected(self) or currentButton.Selected) and self:_GetIsMouseOver(currentButton.Icon) then

            if not AlienBuy_GetIsUpgradeAllowed(currentButton.TechId, self.upgradeList) or currentButton.Purchased then
                -- Play a sound or something to indicate this button isn't clickable.
                PlayerUI_TriggerInvalidSound()
            else
                ToggleButton(self, currentButton)
                inputHandled = true

                if currentButton.Selected then
                    AlienBuy_OnUpgradeSelected()
                else
                    -- Deselect the tier 3 upgrade if the tier 2 get deselected
                    if currentButton.TechId == kTechId.BioMassTwo then
                        for _, button in ipairs(self.upgradeButtons) do
                            if button.TechId == kTechId.BioMassThree and button.Selected then
                                ToggleButton(self, button)
                                break
                            end
                        end
                    end

                    AlienBuy_OnUpgradeDeselected()
                end

            end

            break

        end
    end
    
    return inputHandled

end
debug.joinupvalues(GUIAlienBuyMenu._HandleUpgradeClicked, old_HandleUpgradeClicked)