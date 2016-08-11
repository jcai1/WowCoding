local A = aura_env

-- Constants
local playerGUID = UnitGUID("player")
local band = bit.band
local lastRefresh = 0
local refreshInterval = 0.25

local function isMine(flags)
	return (band(flags, COMBATLOG_OBJECT_AFFILIATION_MINE) ~= 0)
end

local function colorStr(color, str)
	return "|cff" .. color .. str .. "|r"
end

local function print2(str)
	print(colorStr("ffff00", str))
end

local function printf2(fmt, ...)
	print2(format(fmt, ...))
end

local imps = {}

local function createImp(guid)
	local t = GetTime()

	local imp = {
		guid = guid,
		firstEvent = t,
		lastEvent = t,
		sumCasts = 0,
		numCasts = 0,
		sumDamage = 0,
		numDamage = 0
	}

	return imp
end

local function averageStr(sum, num)
	if num == 0 then return "N/A"
	else return format("%.3f", sum / num)
	end
end

local function collectImps()
	local t = GetTime()
	for guid, imp in pairs(imps) do
		if t - imp.lastEvent > 2.5 then
			printf2("Imp: avg cast = %s, avg dmg = %s, duration >= %.3f",
				averageStr(imp.sumCasts, imp.numCasts),
				averageStr(imp.sumDamage, imp.numDamage),
				imp.lastEvent - imp.firstEvent)
			imps[guid] = nil
		end
	end
end

local function impEvent(impGUID)
	if not imps[impGUID] then
		imps[impGUID] = createImp(impGUID)
	end
	local imp = imps[impGUID]
	imp.lastEvent = GetTime()
end

local function impCast(impGUID)
	local t = GetTime()
	local imp = imps[impGUID]
	if not imp.lastCast then
		imp.lastCast = t
	else
		local dt = t - imp.lastCast
		imp.sumCasts = imp.sumCasts + dt
		imp.numCasts = imp.numCasts + 1
		imp.lastCast = t
	end
end

local function impDamage(impGUID, damage)
	local t = GetTime()
	local imp = imps[impGUID]
	imp.sumDamage = imp.sumDamage + damage
	imp.numDamage = imp.numDamage + 1
end

-- COMBAT_LOG_EVENT_UNFILTERED trigger function
local function doCombatTrigger(_, _, subEvent, _,
	sourceGUID, sourceName, sourceFlags, _,
	destGUID, destName, destFlags, _, ...)

	if not (isMine(sourceFlags) or isMine(destFlags)) then
		return
	end

	local t = GetTime()
	print(t, subEvent, sourceName, destName, ...)

	if sourceName == "Wild Imp" then
		if subEvent ~= "SPELL_DAMAGE" then
			impEvent(sourceGUID)
		else
			local baseDamage = select(4, ...)
			if select(10, ...) then baseDamage = baseDamage / 2 end
			impDamage(sourceGUID, baseDamage)
		end
	end

	if destName == "Wild Imp" then
		impEvent(destGUID)
	end

	if subEvent == "SPELL_CAST_SUCCESS" and sourceName == "Wild Imp" then
		impCast(sourceGUID)
	end
end
A.doCombatTrigger = doCombatTrigger

-- Every refreshInterval
local function onRefresh()
	collectImps()
end

-- Every frame
local function onUpdate()
	local t = GetTime()
	if t - lastRefresh > refreshInterval then
		lastRefresh = t
		onRefresh()
	end
end
A.onUpdate = onUpdate
