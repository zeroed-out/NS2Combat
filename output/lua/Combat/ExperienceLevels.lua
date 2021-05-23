-- XP-List
--Table for
--    LVL,  needed XP to reach, RineName, AlienName, givenXP to killer

-- Todo: Make it possible to set up the levels via a config
XpList = {}
XpList[1] =  { Level=1, 	XP=0,		MarineName="Private", 				AlienName="Hatchling",      	GivenXP=60 		}
XpList[2] =  { Level=2, 	XP=100, 	MarineName="Private First Class", 	AlienName="Snark",      		GivenXP=62 		}
XpList[3] =  { Level=3, 	XP=300, 	MarineName="Lance Corporal", 		AlienName="Minion",     		GivenXP=64 		}
XpList[4] =  { Level=4, 	XP=500, 	MarineName="Corporal", 				AlienName="Grunt",      		GivenXP=66 		}
XpList[5] =  { Level=5, 	XP=700, 	MarineName="Sergeant", 				AlienName="Ambusher",    		GivenXP=68 		}
XpList[6] =  { Level=6, 	XP=1000, 	MarineName="Staff Sergeant", 		AlienName="Rampager",      		GivenXP=70 		}
XpList[7] =  { Level=7, 	XP=1300, 	MarineName="Gunnery Sergeant", 		AlienName="Bruiser",    		GivenXP=72		}
XpList[8] =  { Level=8, 	XP=1600, 	MarineName="First Sergeant", 		AlienName="Slaughterer",        GivenXP=75		}
XpList[9] =  { Level=9, 	XP=1900, 	MarineName="Sergeant Major", 		AlienName="Executioner",      	GivenXP=78		}
XpList[10] = { Level=10, 	XP=2200, 	MarineName="2nd Lieutenant", 		AlienName="Super Mutant",      	GivenXP=83		}
XpList[11] = { Level=11, 	XP=2600, 	MarineName="1st Lieutenant", 		AlienName="Behemoth",     		GivenXP=87		}
XpList[12] = { Level=12, 	XP=3000, 	MarineName="Captain", 				AlienName="Guardian",     		GivenXP=91		}
XpList[13] = { Level=13, 	XP=3500, 	MarineName="Major", 			 	AlienName="Overlord",        	GivenXP=95		}
XpList[14] = { Level=14, 	XP=4000, 	MarineName="Lieutenant Colonel", 	AlienName="Abomination",      	GivenXP=100		}
XpList[15] = { Level=15, 	XP=4500, 	MarineName="Colonel", 				AlienName="Nightmare",   		GivenXP=105		}
XpList[16] = { Level=16, 	XP=5000, 	MarineName="Brigadier General", 	AlienName="Mind Flayer",  		GivenXP=110		}
XpList[17] = { Level=17, 	XP=5600, 	MarineName="Major General", 		AlienName="Unstoppable Fury",   GivenXP=120		}
XpList[18] = { Level=18, 	XP=6300, 	MarineName="Lieutenant General", 	AlienName="Hive Mind",          GivenXP=130		}
XpList[19] = { Level=19, 	XP=7100, 	MarineName="Commander", 		  	AlienName="Scourge of Sanji",   GivenXP=150		}
XpList[20] = { Level=20, 	XP=8000, 	MarineName="Hero of Sanji", 		AlienName="Demigod", 			GivenXP=250		}

maxLvl = #XpList
maxXp = XpList[maxLvl]["XP"]

function Experience_GetLvl(xp)
	
	local returnlevel = 1
	
	-- Look up the level of this amount of Xp
	if xp >= maxXp then
		return maxLvl
	end
	
	for index, thislevel in ipairs(XpList) do
		
		if xp >= thislevel["XP"] and
				xp < XpList[index+1]["XP"] then
			
			returnlevel = thislevel["Level"]
		
		end
	
	end
	
	return returnlevel
end

function Experience_GetLvlName(lvl, team)
	
	local LvlName = ""
	if (team == 1) then
		LvlName = XpList[lvl]["MarineName"]
	else
		LvlName = XpList[lvl]["AlienName"]
	end
	
	return LvlName

end

function Experience_XpForLvl(lvl)
	
	local returnXp = XpList[1]["XP"]
	
	if lvl > 0 then
		returnXp = XpList[lvl]["XP"]
	end
	
	return returnXp
end