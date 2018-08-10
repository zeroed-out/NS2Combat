--Todo: refactor this Mixin in Vanilla to make it easier to increase the amount of upgrades
UpgradableMixin.networkVars =
{
    upgrade1 = "enum kTechId",
    upgrade2 = "enum kTechId",
    upgrade3 = "enum kTechId",
    upgrade4 = "enum kTechId",
    upgrade5 = "enum kTechId",
    upgrade6 = "enum kTechId",
    upgrade7 = "enum kTechId",
    upgrade8 = "enum kTechId",
    upgrade9 = "enum kTechId",
    upgrade10 = "enum kTechId",
    upgrade11 = "enum kTechId",
    upgrade12 = "enum kTechId",
}

function UpgradableMixin:__initmixin()

    self.upgrade1 = kTechId.None
    self.upgrade2 = kTechId.None
    self.upgrade3 = kTechId.None
    self.upgrade4 = kTechId.None
    self.upgrade5 = kTechId.None
    self.upgrade6 = kTechId.None
    self.upgrade7 = kTechId.None
    self.upgrade8 = kTechId.None
    self.upgrade9 = kTechId.None
    self.upgrade10 = kTechId.None
    self.upgrade11 = kTechId.None
    self.upgrade12 = kTechId.None

end

function UpgradableMixin:GetHasUpgrade(techId)

    return techId ~= kTechId.None and (techId == self.upgrade1 or techId == self.upgrade2 or techId == self.upgrade3
            or techId == self.upgrade4 or techId == self.upgrade5 or techId == self.upgrade6
            or techId == self.upgrade7 or techId == self.upgrade8 or techId == self.upgrade9
            or techId == self.upgrade10)

end

function UpgradableMixin:GetUpgradeList()

    local list = { self.upgrade1, self.upgrade2, self.upgrade3, self.upgrade4, self.upgrade5, self.upgrade6, self.upgrade7, self.upgrade8, self.upgrade9, self.upgrade10 }

    for i = #list, 1 , -1 do

        local upgrade = list[i]
        local techTree = GetTechTree(self:GetTeamNumber())

        if upgrade == kTechId.None or ( techTree and not techTree:GetIsTechAvailable(upgrade) ) then
            table.remove(list, i)
        end

    end

    return list

end

function UpgradableMixin:GetUpgrades()

    local upgrades = { }

    if self.upgrade1 ~= kTechId.None then
        table.insert(upgrades, self.upgrade1)
    end
    if self.upgrade2 ~= kTechId.None then
        table.insert(upgrades, self.upgrade2)
    end
    if self.upgrade3 ~= kTechId.None then
        table.insert(upgrades, self.upgrade3)
    end
    if self.upgrade4 ~= kTechId.None then
        table.insert(upgrades, self.upgrade4)
    end
    if self.upgrade5 ~= kTechId.None then
        table.insert(upgrades, self.upgrade5)
    end
    if self.upgrade6 ~= kTechId.None then
        table.insert(upgrades, self.upgrade6)
    end
    if self.upgrade7 ~= kTechId.None then
        table.insert(upgrades, self.upgrade7)
    end
    if self.upgrade8 ~= kTechId.None then
        table.insert(upgrades, self.upgrade8)
    end
    if self.upgrade9 ~= kTechId.None then
        table.insert(upgrades, self.upgrade9)
    end
    if self.upgrade10 ~= kTechId.None then
        table.insert(upgrades, self.upgrade10)
    end
    if self.upgrade11 ~= kTechId.None then
        table.insert(upgrades, self.upgrade11)
    end
    if self.upgrade12 ~= kTechId.None then
        table.insert(upgrades, self.upgrade12)
    end

    return upgrades

end

function UpgradableMixin:GiveUpgrade(techId)

    local upgradeGiven = false

    if not self:GetHasUpgrade(techId) then

        if self.upgrade1 == kTechId.None then

            self.upgrade1 = techId
            upgradeGiven = true

        elseif self.upgrade2 == kTechId.None then

            self.upgrade2 = techId
            upgradeGiven = true

        elseif self.upgrade3 == kTechId.None then

            self.upgrade3 = techId
            upgradeGiven = true

        elseif self.upgrade4 == kTechId.None then

            self.upgrade4 = techId
            upgradeGiven = true

        elseif self.upgrade5 == kTechId.None then

            self.upgrade5 = techId
            upgradeGiven = true

        elseif self.upgrade6 == kTechId.None then

            self.upgrade6 = techId
            upgradeGiven = true

        elseif self.upgrade7 == kTechId.None then

            self.upgrade7 = techId
            upgradeGiven = true

        elseif self.upgrade8 == kTechId.None then

            self.upgrade8 = techId
            upgradeGiven = true

        elseif self.upgrade9 == kTechId.None then

            self.upgrade9 = techId
            upgradeGiven = true

        elseif self.upgrade10 == kTechId.None then

            self.upgrade10 = techId
            upgradeGiven = true

        elseif self.upgrade11 == kTechId.None then

            self.upgrade11 = techId
            upgradeGiven = true

        elseif self.upgrade12 == kTechId.None then

            self.upgrade12 = techId
            upgradeGiven = true

        end

        assert(upgradeGiven, "Entity already has the max of 12 upgrades. What are you doing?!?")

    end

    if upgradeGiven and self.OnGiveUpgrade then
        self:OnGiveUpgrade(techId)
    end

    return upgradeGiven

end

function UpgradableMixin:RemoveUpgrade(techId)

    local removed = false

    if self:GetHasUpgrade(techId) then

        if self.upgrade1 == techId then

            self.upgrade1 = kTechId.None
            removed = true

        elseif self.upgrade2 == techId then

            self.upgrade2 = kTechId.None
            removed = true

        elseif self.upgrade3 == techId then

            self.upgrade3 = kTechId.None
            removed = true

        elseif self.upgrade4 == techId then

            self.upgrade4 = kTechId.None
            removed = true

        elseif self.upgrade5 == techId then

            self.upgrade5 = kTechId.None
            removed = true

        elseif self.upgrade6 == techId then

            self.upgrade6 = kTechId.None
            removed = true

        elseif self.upgrade7 == techId then

            self.upgrade7 = kTechId.None
            removed = true

        elseif self.upgrade8 == techId then

            self.upgrade8 = kTechId.None
            removed = true

        elseif self.upgrade9 == techId then

            self.upgrade9 = kTechId.None
            removed = true

        elseif self.upgrade10 == techId then

            self.upgrade10 = kTechId.None
            removed = true

        elseif self.upgrade11 == techId then

            self.upgrade10 = kTechId.None
            removed = true

        elseif self.upgrade12 == techId then

            self.upgrade10 = kTechId.None
            removed = true

        end

    end

    return removed

end

function UpgradableMixin:ClearUpgrades()

    self.upgrade1 = kTechId.None
    self.upgrade2 = kTechId.None
    self.upgrade3 = kTechId.None
    self.upgrade4 = kTechId.None
    self.upgrade5 = kTechId.None
    self.upgrade6 = kTechId.None
    self.upgrade7 = kTechId.None
    self.upgrade8 = kTechId.None
    self.upgrade9 = kTechId.None
    self.upgrade10 = kTechId.None
    self.upgrade11 = kTechId.None
    self.upgrade12 = kTechId.None

end