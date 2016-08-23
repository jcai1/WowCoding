local A = aura_env
local playerGUID = UnitGUID("player")
local now

local t = {}
MySaved.TrinketTest=t
local lastDarkBlast

print("Reset TrinketTest")

local filteredSpellNames = {
	["Compounding Horror"] = true,
	["Harvester of Souls"] = true,
	["Tormented Souls"] = true,
	["Corruption"] = true,
}

local function log(spellName, type)
	if filteredSpellNames[spellName] then return end
	local key = spellName.."_"..type
	t[key] = t[key] or {}
	if spellName == "Dark Blast" then
		if lastDarkBlast ~= now then
			tinsert(t[key], now)
			lastDarkBlast = now
		end
	else
		tinsert(t[key], now)
	end
end

local function doCombatTrigger(_,_,subEvent,_,sourceGUID,sourceName,sourceFlags,_,destGUID,destName,destFlags,_,spellID,spellName,_,...)
	now = GetTime()
	if sourceGUID == playerGUID then
		if subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REFRESH" then
			log(spellName, "aura")
		elseif subEvent == "SPELL_DAMAGE" then
			log(spellName, "damage")
		end
	end
end
A.doCombatTrigger = doCombatTrigger

/run wipe(MySaved.TrinketTest) MySaved.TrinketTest.startTime = GetTime()
/run for k,t in pairs(MySaved.TrinketTest)do if type(t)=="table"then print(k, #t/(GetTime()-MySaved.TrinketTest.startTime)*60)end end