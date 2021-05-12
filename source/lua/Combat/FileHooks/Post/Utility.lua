-- Utility.lua

-- Used to send messages to all players.
function SendGlobalChatMessage(message)
	local allPlayers = Shared.GetEntitiesWithClassname("Player")
	if (allPlayers:GetSize() > 0) then
		for _, player in ientitylist(allPlayers) do
			player:SendDirectMessage(message)
		end
	end
	
	-- Also output to the console for admins.
	Shared.Message(message)
end

-- Gets the time in the format "[m minutes,] s seconds"
function GetTimeText(timeInSeconds)

	local timeLeftText = ""
	local timeNumericSeconds = math.abs(tonumber(timeInSeconds))
	ASSERT(timeNumericSeconds >= 0)
	if (timeNumericSeconds > 60) then
		timeLeftText = math.floor(timeNumericSeconds/60) .." minutes"
	elseif (timeNumericSeconds == 60) then
		timeLeftText = "1 minute"
	end
	
	
	if (timeNumericSeconds > 60 and timeNumericSeconds % 60 ~= 0) then
		timeLeftText = timeLeftText .. ", "
	end
	
	if (timeNumericSeconds % 60 ~= 0) then
		if (timeNumericSeconds % 60 == 1) then
			timeLeftText = timeLeftText .. "1 second"
		else
			timeLeftText = timeLeftText .. (timeNumericSeconds % 60) .." seconds"
		end
	end
	return timeLeftText

end

-- Gets the time in the format "mm:ss:ms"
function GetTimeDigital(timeInSeconds, showMinutes, showHundredths)

	local timeLeftText = ""
	local timeNumericSeconds = tonumber(timeInSeconds)
	if (timeNumericSeconds < 0) then 
		timeLeftText = "- "
	end
	timeNumericSeconds = math.abs(tonumber(timeInSeconds))
	
	if showMinutes then
		local timeLeftMinutes = math.floor(timeNumericSeconds/60)
		if (timeLeftMinutes < 10) then
			timeLeftText = timeLeftText .. "0" .. timeLeftMinutes
		else
			timeLeftText = timeLeftText .. timeLeftMinutes
		end
	
		timeLeftText = timeLeftText .. ":"
	end
	
	local timeLeftSeconds = math.floor(timeNumericSeconds % 60)
	if (timeLeftSeconds < 10) then
		timeLeftText = timeLeftText .. "0" .. timeLeftSeconds
	else
		timeLeftText = timeLeftText .. timeLeftSeconds
	end
	
	-- Disable milliseconds by default. They are *really* annoying.
	if showHundredths then
		timeLeftText = timeLeftText .. "."
	
		local timeLeftHundredths = math.ceil((timeNumericSeconds * 100) % 100)
		if (timeLeftHundredths < 10) then
			timeLeftText = timeLeftText .. "0" .. timeLeftHundredths
		else
			timeLeftText = timeLeftText .. timeLeftHundredths
		end
	end
	
	return timeLeftText

end

function GetHasTimelimitPassed()
	if Server then
		return GetGamerules():GetHasTimelimitPassed()
	elseif Client then
		return PlayerUI_GetHasTimelimitPassed()
	else
		return false --Predict
	end
end

function GetTimeLeftMessage(timeleft, teamNumber)
	local message = ""
	if kCombatAllowOvertime then
		message = "left until overtime!"
	elseif kCombatDefaultWinner == kTeam2Index then
		message = teamNumber == kTeam1Index and "left until Marines have lost!" or
				"left until Aliens have won!"
	else
		message = teamNumber == kTeam1Index and "left until Marines have won!" or
				"left until Aliens have lost!"
	end

	return string.format("%s %s", timeleft, message)
end