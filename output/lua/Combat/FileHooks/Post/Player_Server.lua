-- function for spawn protect
function Player:SetSpawnProtect()

    self.combatTable.activeSpawnProtect = true
    self.combatTable.deactivateSpawnProtect = nil

end

function Player:DeactivateSpawnProtect()

    self:SetHealth( self:GetMaxHealth() )
    self:SetArmor( self:GetMaxArmor() )

    self.combatTable.activeSpawnProtect = nil
    self.gotSpawnProtect = nil

    -- Deactivate the nano shield by manipulating the time variable.
    self.timeNanoShieldInit = 0

end

function Player:PerformSpawnProtect()

    -- Only make the effects once.
    if not self.gotSpawnProtect then

        -- Fire the effects on a slight delay because something in the NS2 code normally clears it first!
        if not self.spawnProtectActivateTime then

            self.spawnProtectActivateTime = Shared.GetTime() + kCombatSpawnProtectDelay

        elseif Shared.GetTime() >= self.spawnProtectActivateTime then

            if HasMixin(self, "NanoShieldAble") then

                self:ActivateNanoShield()
                if self.nanoShielded then
                    self.gotSpawnProtect = true
                end

            elseif self:isa("Alien") then

                local spawnProtectTimeLeft = self.combatTable.deactivateSpawnProtect - Shared.GetTime()
                self:SetHasUmbra(true, spawnProtectTimeLeft)
                self.gotSpawnProtect = true

            end

        end

    end

end


-- Resup and Scan function

function Player:ScanNow()

    local position = self:GetOrigin()

    CreateEntity(Scan.kMapName, position, self:GetTeamNumber())
    StartSoundEffectAtOrigin(Observatory.kCommanderScanSound, position)

    self.combatTable.lastScan = Shared.GetTime()

end

function Player:NeedsResupply()

    -- Ammo packs give ammo to clip as well (so pass true to GetNeedsAmmo())
    -- check every weapon the player got
    local weapon = self:GetActiveWeapon()
    local needsHealth = not GetIsVortexed(self) and self:GetHealth() < self:GetMaxHealth()
    local needsAmmo = false

    for i = 0, self:GetNumChildren() - 1 do

        local child = self:GetChildAtIndex(i)
        if child:isa("ClipWeapon") then

            needsAmmo = child ~= nil and child:GetNeedsAmmo(false) and not GetIsVortexed(self)
            if needsAmmo then
                break
            end

        end

    end

    return needsAmmo or needsHealth

end

function Player:ResupplyNow()

    self.timeLastMedpack = false -- disables medpack pickup delay
    MedPack.OnTouch(self, self)

    -- dont drop a ammo pack, give ammo via a new function
    self:GiveAmmoToEveryWeapon()

    return true

end

function Player:GiveAmmoToEveryWeapon()

    for i = 0, self:GetNumChildren() - 1 do

        local child = self:GetChildAtIndex(i)
        if child:isa("ClipWeapon") then

            if child:GetNeedsAmmo(false) then
                child:GiveAmmo(AmmoPack.kNumClips, false)
            end

        end

    end

    StartSoundEffectAtOrigin(AmmoPack.kPickupSound, self:GetOrigin())

end

function Player:CatalystNow()

    local success = false
    local globalSound = CatPack.kPickupSound
    local localSound = "sound/NS2.fev/marine/common/mine_warmup"

    -- Use one sound for global, another for local player to give more of an effect!
    StartSoundEffectAtOrigin(globalSound, self:GetOrigin())
    StartSoundEffectForPlayer(localSound, self)
    self:ApplyCatPack()
    success = true
    self:SendDirectMessage("You now have catalyst for " .. kCatPackDuration .. " secs!")
    return success

end

function Player:CheckCatalyst()

    local timeNow = Shared.GetTime()

    if self.combatTable.hasCatalyst and self:isa("Marine") then

        if not self.combatTable.lastCatalyst or (timeNow >= self.combatTable.lastCatalyst + kCatalystTimer + kCatPackDuration) then
            local success = self:CatalystNow()
            if success then
                self.combatTable.lastCatalyst = timeNow
            end
        end

    end

end

function Player:EMPBlast()

    local empBlast = CreateEntity(EMPBlast.kMapName, self:GetOrigin(), self:GetTeamNumber())

end


function Player:TriggerInk()

    -- Create ShadeInk entity in world at this position with a small offset
    local shadeInk = CreateEntity(ShadeInk.kMapName, self:GetOrigin() + Vector(0, 0.2, 0), self:GetTeamNumber())
    StartSoundEffectOnEntity("sound/NS2.fev/alien/structures/shade/cloak_triggered", shadeInk)

end


function Player:GetXp()
    if self.score then
        return self.score
    else
        return 0
    end
end

function Player:GetLvl()
    if self.combatTable then
        return Experience_GetLvl(self:GetXp())
    else
        return 1
    end
end

function Player:GetLvlFree()

    if self.combatTable then
        return self.resources
    else
        return 0
    end

end

function Player:AddLvlFree(amount)

    if amount == nil then
        amount = 1
    end

    self.resources = self.resources + amount

end

function Player:SubtractLvlFree(amount)

    if amount == nil then
        amount = 1
    end

    self.resources = self.resources - amount

    if self.resources < 0 then
        self.resources = 0
    end

end

function Player:ClearLvlFree()

    self.resources = 0

end

function Player:ClearCombatData()

    -- Blow away the old combatTable amd combatTechTree then re-run the check
    self.combatTable = nil
    self.combatTechTree = nil
    self:CheckCombatData()

end

function Player:CheckCombatData()

    -- Initialise the Combat Tech Tree
    if not self.combatTable then
        self:ResetCombatData()
    end

    if not self.combatTechTree then

        -- Also create a personal version of the tech tree.
        local team = self:GetTeam()
        if team and team:isa("PlayingTeam") then
            self.combatTechTree = TechTree()
            self.combatTechTree:CopyDataFrom(team:GetTechTree())
            self.combatTechTree:ComputeAvailability()
        end

    end

end

function Player:UpdateTechTree()

    self:CheckCombatData()

    if self.combatTechTree then
        self.combatTechTree:Update({})
    end

end

function Player:AddXp(amount)

    self:CheckCombatData()
    --self:TriggerEffects("issueOrderSounds")

    -- check if amount isn't nil, could cause an error
    if amount and amount > 0 then
        if (amount > 10) then
            self:TriggerEffects("combat_xp")
        end

        -- show the cool effect, no direct Message is needed anymore
        self:XpEffect(amount)
        self:CheckLvlUp(self.score)
        --self:SetScoreboardChanged(true)
    end
end

-- Give XP to m8's around you when you kill an enemy
function Player:GiveXpMatesNearby(xp)

    xp = xp * mateXpAmount

    local playersInRange = GetEntitiesForTeamWithinRange("Player", self:GetTeamNumber(), self:GetOrigin(), mateXpRange)

    -- Only give Xp to players who are alive!
    for _, player in ipairs(playersInRange) do
        if self ~= player and player:GetIsAlive() then
            player:AddXp(xp)
        end
    end

end

-- cool effect for getting xp, also showing a new Lvl
function Player:XpEffect(xp, lvl)

    -- Should only be called on the Server.
    if Server then

        if xp ~= nil and xp ~= 0 then

            self.score = Clamp(self.score + xp, 0, self:GetMixinConstants().kMaxScore or 100)
            local lastXpEffect = self.combatTable.lastXpEffect
            -- dont spam the player with xpeffects
            if lastXpEffect == 0 or Shared.GetTime() >= ( lastXpEffect + kXPEffectTimer) then

                -- show also old xp award, but forget it after some time
                if self.combatTable.lastXpAmount > 0 and Shared.GetTime() < ( lastXpEffect + kXPForgetTimer) then
                    xp = xp + self.combatTable.lastXpAmount
                end

                Server.SendCommand(self, string.format("points %s %s", tostring(xp), tostring(0)))
                self.combatTable.lastXpEffect = Shared.GetTime()
                self.combatTable.lastXpAmount = 0
            else
                -- save the last XpAmount and sum it
                self.combatTable.lastXpAmount = self.combatTable.lastXpAmount + xp
            end


        end


    end

end

function Player:CheckLvlUp(xp)

    if self:GetLvl() > self.combatTable.lvl then
        --Lvl UP
        -- make sure that we get every lvl we've earned
        local numberLevels = self:GetLvl() - self.combatTable.lvl
        self.resources = self.resources + numberLevels
        self.combatTable.lvl = self:GetLvl()

        -- Trigger sound on level up
        if (self:isa("Alien")) then
            StartSoundEffectForPlayer(CombatEffects.kAlienLvlUpSound, self)
        else
            StartSoundEffectForPlayer(CombatEffects.kMarineLvlUpSound, self)
        end

        -- Trigger an effect
        self:TriggerEffects("combat_level_up")

        SendCombatLvlUp(self)

    end

end

function Player:spendlvlHints(hint, type)
    -- sends a hint to the player if co_spendlvl fails

    if not type then type = "" end

    if hint == "spectator" then
        self:SendDirectMessage("You can only apply upgrades once you've joined a team!")

    elseif hint == "dead" then
        self:SendDirectMessage("You cannot apply upgrades if you are dead!")

    elseif hint == "no_type" then
        self:SendDirectMessage("Usage: /buy upgradeName or co_spendlvl upgradeName - All upgrades for your team:")
        Server.ClientCommand(self, "co_upgrades")

    elseif hint == "wrong_type_marine" then
        self:SendDirectMessage(  type .. " is not known. All upgrades for your team:")
        Server.ClientCommand(self, "co_upgrades")

    elseif hint == "wrong_type_alien" then
        self:SendDirectMessage(  type .. " is not known. All upgrades for your team:")
        Server.ClientCommand(self, "co_upgrades")

    elseif hint == "neededOtherUp" then
        self:SendDirectMessage( "You need " .. type .. " first")

    elseif hint == "neededLvl" then
        self:SendDirectMessage("You got only " .. self:GetLvlFree().. " but you need at least ".. type .. " free Lvl")

    elseif hint == "already_owned" then
        -- Suppress this now as most people buy via the menus.
        --self:SendDirectMessage("You already own the upgrade " .. type)

    elseif hint == "no_room" then
        self:SendDirectMessage( type .." upgrade failed, maybe not enough room")

    elseif hint == "not_in_techrange" then
        local techType = ""

        if type == "Alien" then
            techType = "Hive to evolve to an Onos"
        else
            techType = "Command Station to get an Exosuit"
        end
        self:SendDirectMessage("You have to be near the " .. techType .. "!")

    elseif hint == "heavytech_cooldown" then
        local techType = ""

        if type == "Alien" then
            techType = "evolving to an Onos"
        else
            techType = "buying an Exosuit"
        end
        self:SendDirectMessage("You have to wait " .. math.floor(kHeavyTechCooldown - (Shared.GetTime() - self.combatTable.timeLastHeavyTech)) .. " seconds for " .. techType .. " again!")

    elseif hint == "wrong_team" then
        local teamtext = ""
        if type == "Alien" then
            teamtext = "an Alien"
        else
            teamtext = "a Marine"
        end
        self:SendDirectMessage( "Cannot take this upgrade. You are not " .. teamtext .. "!" )

    elseif hint == "mutuallyExclusive" then
        self:SendDirectMessage( "Cannot buy this upgrade when you have the " .. type .. " upgrade!")

    elseif hint == "hardCapped" then
        self:SendDirectMessage( "Cannot buy this upgrade.")
        self:SendDirectMessage( "Only 1 player may take this upgrade for every 5 players in your team." )

    elseif hint == "freeLvl" then
        local lvlFree = self:GetLvlFree()
        local upgradeWord = (lvlFree > 1) and "upgrades" or "upgrade"
        self:SendDirectMessage("You have " .. lvlFree .. " " .. upgradeWord .. " to spend. Use \"/buy <upgrade>\" in chat to buy upgrades.")

    end
end

function Player:SendDirectMessage(message)

    -- Initialise queue if necessary
    if (self.directMessageQueue == nil) then
        self.directMessageQueue = {}
        self.timeOfLastDirectMessage = 0
        self.directMessagesActive = 0
    end

    -- Queue messages that have been sent if there are too many...
    if (Shared.GetTime() - self.timeOfLastDirectMessage < kDirectMessageFadeTime and self.directMessagesActive + 1 > kDirectMessagesNumVisible) then
        table.insert(self.directMessageQueue, message)
    else
        -- Otherwise we're good to send the message normally.
        self:BuildAndSendDirectMessage(message)
    end

    -- Update the last sent timer if this is the first message sent.
    if (self.directMessagesActive == 0) then
        self.timeOfLastDirectMessage = Shared.GetTime()
    end
    self.directMessagesActive = self.directMessagesActive + 1

end

function Player:BuildAndSendDirectMessage(message)


    Server.SendNetworkMessage(self, "CombatMessage", {message = message}, true)

end

function Player:ProcessTauntAbilities()

    if self.combatTable then
        if self.combatTable.hasEMP then
            if  self.combatTable.lastEMP == 0 or Shared.GetTime() >= ( self.combatTable.lastEMP + kEMPTimer) then
                self:EMPBlast()
                self.combatTable.lastEMP = Shared.GetTime()
            else
                local timeReady = math.ceil(self.combatTable.lastEMP + kEMPTimer - Shared.GetTime())
                self:SendDirectMessage("EMP-taunt is not ready, wait " .. timeReady .. " sec")
            end
        elseif self.combatTable.hasInk then
            if self.combatTable.lastInk == 0 or Shared.GetTime() >= ( self.combatTable.lastInk + kInkTimer) then
                self:TriggerInk()
                self.combatTable.lastInk = Shared.GetTime()
            else
                local timeReady = math.ceil(self.combatTable.lastInk + kInkTimer - Shared.GetTime())
                self:SendDirectMessage("Ink-taunt is not ready, wait " .. timeReady .. " sec")
            end
        end
    end

end

-- Implement lvl and XP
local oldReset = Player.Reset
function Player:Reset()
    oldReset(self)

    self:ResetCombatData()
end

-- Copy old lvl and XP when respawning
local oldCopyPlayerDataFrom = Player.CopyPlayerDataFrom
function Player:CopyPlayerDataFrom(player)

    oldCopyPlayerDataFrom(self, player)

    self.combatTable = player.combatTable

end

function Player:GetTechTree()

    self:CheckCombatData()

    return self.combatTechTree

end

local oldOnCreate = Player.OnCreate
function Player:OnCreate()
    oldOnCreate(self)

    -- Set up the timers for repetitive check events.
    -- This should improve performance somewhat as well.
    self:AddTimedCallback(self.CombatHandleQueuedMessages, 1)
    self.lastReminderNotify = Shared.GetTime()

end

function Player:CombatHandleQueuedMessages()

    -- Handle queued direct messages.
    if (self.directMessagesActive ~= nil and self.directMessagesActive > 0) then
        if (Shared.GetTime() - self.timeOfLastDirectMessage > kDirectMessageFadeTime) then

            -- After the fade time has passed, clear old messages from the queue.
            for msgIndex = 1, math.min(self.directMessagesActive, kDirectMessagesNumVisible) do
                self.directMessagesActive = self.directMessagesActive - 1
            end

            -- Send any waiting messages, up to kDirectMessagesNumVisible.
            if (#self.directMessageQueue > 0) then
                for msgIndex = 1, math.min(#self.directMessageQueue, kDirectMessagesNumVisible) do
                    local message = table.remove(self.directMessageQueue, 1)
                    self:BuildAndSendDirectMessage(message)
                end

                self.timeOfLastDirectMessage = Shared.GetTime()
            end

        end
    end

    return true

end

-- Various updates and timers in here.
local oldOnUpdatePlayer = Player.OnUpdatePlayer
function Player:OnUpdatePlayer(deltaTime)

    oldOnUpdatePlayer(self, deltaTime)

    -- Spawn Protect
    self:CheckCombatData()
    if self.combatTable.activeSpawnProtect then

        if self:GetIsAlive() and (self:GetTeamNumber() == 1 or self:GetTeamNumber() == 2) then

            if not self.combatTable.deactivateSpawnProtect then
                -- set the real spawn protect time here
                local spawnProtectTime = 0
                if self:isa("Alien") then
                    spawnProtectTime = kCombatAlienSpawnProtectTime
                else
                    spawnProtectTime = kCombatMarineSpawnProtectTime
                end

                self.combatTable.deactivateSpawnProtect = Shared.GetTime() +  kCombatMarineSpawnProtectTime
            end

            if Shared.GetTime() >= self.combatTable.deactivateSpawnProtect then
                -- end spawn protect
                self:DeactivateSpawnProtect()
            else
                if not self.gotSpawnProtect then
                    self:PerformSpawnProtect()
                end
            end
        end

    end

    -- Putting this here to try and fix the giving xp on join.
    -- Also helps us write the xp balancing function later.
    if self:GetIsPlaying() then
        if self.combatTable.setAvgXp then
            local avgXp = Experience_GetAvgXp(self)
            -- Send the avg as a message to the player (%d doesn't work with SendDirectMessage)
            self:BalanceXp(avgXp)

            -- Reset the average Xp flag.
            self.combatTable.setAvgXp = false
        end
    end

    -- only trigger Scan and Resupply when player is alive
    if self:GetIsAlive() then

        -- Provide scan and resupply function
        if self.combatTable.hasScan then
        
            if (self.combatTable.lastScan + kScanTimer < Shared.GetTime()) then

                self:ScanNow()

            end
        end

        if self.combatTable.hasResupply then
            if (self.combatTable.lastResupply + deltaTime >= kResupplyTimer) then

                -- Keep the timer going, even if we don't need to resupply.
                local success = false
                if (self:NeedsResupply()) then
                    success = self:ResupplyNow()
                else
                    success = true
                end

                if success then
                    self.combatTable.lastResupply = 0
                end
            else
                self.combatTable.lastResupply = self.combatTable.lastResupply + deltaTime
            end
        end

        if self.poweringUpFinishedTime then
            if Shared.GetTime() >= self.poweringUpFinishedTime then
                self:SetCameraDistance(0)
                self:RetrieveMove()
                self:SendDirectMessage("You can move again!")
                self.poweringUpFinishedTime = nil
            end
        end
    end
end

function Player:OnTaunt()
    self:CheckCombatData()

    if Shared.GetTime() - self.combatTable.lastTauntTime > kCombatTauntCheckInterval then
        self:ProcessTauntAbilities()
        self.combatTable.lastTauntTime = Shared.GetTime()
    end
end