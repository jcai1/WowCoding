local A = aura_env

-- Constants
local playerGUID = UnitGUID("player")
local band = bit.band
local colors = {"ff0000", "00ff00", "3333ff", "ffff00", "ff00ff", "00ffff"}
local dreadColor = 1

local function isMine(flags)
	return (band(flags, COMBATLOG_OBJECT_AFFILIATION_MINE) ~= 0)
end

local function colorStr(color, str)
	return "|cff" .. color .. str .. "|r"
end

local dreads = {}

local function createDread(guid)
	local t = GetTime()

	local dread = {
		guid = guid,
		color = colors[dreadColor],
		firstEvent = t,
		lastEvent = t,
		sumSwings = 0,
		numSwings = 0
	}

	dreadColor = dreadColor + 1
	if dreadColor > #colors then
		dreadColor = 1
	end

	print(colorStr(dread.color, "Dread created"))
	return dread
end

local function collectDreads()
	local t = GetTime()
	for guid, dread in pairs(dreads) do
		if t - dread.lastEvent > 5 then
			print(colorStr(dread.color,
				format("Dread expired, duration >= %.3f", dread.lastEvent - dread.firstEvent)
				))
			dreads[guid] = nil
		end
	end
end

local function dreadEvent(dreadGUID)
	if not dreads[dreadGUID] then
		dreads[dreadGUID] = createDread(dreadGUID)
	end
	local dread = dreads[dreadGUID]
	dread.lastEvent = GetTime()
end

local function dreadMelee(dreadGUID)
	local t = GetTime()
	local dread = dreads[dreadGUID]
	if not dread.lastMelee then
		dread.lastMelee = t
	else
		local dt = t - dread.lastMelee
		dread.sumSwings = dread.sumSwings + dt
		dread.numSwings = dread.numSwings + 1
		print(colorStr(dread.color,
			format("%.3f (average %.3f)", dt, dread.sumSwings / dread.numSwings)
			))
		dread.lastMelee = t
	end
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

	if sourceName == "Dreadstalker" then
		dreadEvent(sourceGUID)
	end

	if destName == "Dreadstalker" then
		dreadEvent(destGUID)
	end

	if subEvent == "SWING_DAMAGE" and sourceName == "Dreadstalker" then
		dreadMelee(sourceGUID)
	end

	collectDreads()
end
A.doCombatTrigger = doCombatTrigger
