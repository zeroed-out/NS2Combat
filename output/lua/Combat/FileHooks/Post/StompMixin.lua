-- changed it from tierthree to tiertwo
function StompMixin:GetHasSecondary(player)
    return GetIsTechUnlocked(player, kTechId.Stomp)
end